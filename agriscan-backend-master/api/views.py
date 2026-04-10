from django.utils import timezone
from django.shortcuts import render
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.core.mail import send_mail
from django.conf import settings
from rest_framework.response import Response
from rest_framework import status, views
from rest_framework_simplejwt.tokens import RefreshToken
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import OTPVerification
import random
import string
from rest_framework.permissions import IsAuthenticated

class LoginView(views.APIView):
    """
    User login endpoint that returns JWT tokens.
    
    Accepts email/phone and password, authenticates the user,
    and returns access and refresh JWT tokens.
    """
    
    @swagger_auto_schema(
        operation_description="Login with email/phone and password to get JWT tokens",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
                'phone': openapi.Schema(type=openapi.TYPE_STRING, description='User phone number'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='User password'),
            },
            required=['password'],
        ),
        responses={
            200: openapi.Response(
                description='Login successful',
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'access': openapi.Schema(type=openapi.TYPE_STRING, description='JWT access token'),
                        'refresh': openapi.Schema(type=openapi.TYPE_STRING, description='JWT refresh token'),
                    }
                )
            ),
            400: 'Bad request - missing required fields',
            401: 'Unauthorized - invalid credentials',
            403: 'Forbidden - account not active',
        }
    )
    def post(self, request):
        email_or_phone = request.data.get("email") or request.data.get("phone")
        password = request.data.get("password")

        # Validate input
        if not email_or_phone or not password:
            return Response({"error": "Email/Phone and password required"}, status=status.HTTP_400_BAD_REQUEST)

        # Try to find user by email or username
        try:
            user = User.objects.get(email=email_or_phone)
        except User.DoesNotExist:
            # If not found by email, try as username
            user = None

        # Authenticate user
        if user:
            user = authenticate(username=user.username, password=password)
        else:
            user = authenticate(username=email_or_phone, password=password)

        if user is None:
            return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

        # Check if user is active (e.g., OTP verified)
        if not user.is_active:
            return Response({"error": "Account not active"}, status=status.HTTP_403_FORBIDDEN)

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        access = refresh.access_token

        # Optional: store device info or last login
        user.last_login = timezone.now()
        user.save(update_fields=["last_login"])

        return Response({
            "access": str(access),
            "refresh": str(refresh),
        }, status=status.HTTP_200_OK)


class SignupView(views.APIView):
    """
    User signup endpoint with OTP verification via email.
    
    Step 1: User provides full name, email, password and confirm password to initiate signup
    Step 2: OTP is sent to the email
    Step 3: User verifies OTP to complete registration
    """
    
    @swagger_auto_schema(
        operation_description="Initiate signup - sends OTP to email",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'full_name': openapi.Schema(type=openapi.TYPE_STRING, description='User full name'),
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='User password'),
                'confirm_password': openapi.Schema(type=openapi.TYPE_STRING, description='Confirm password'),
            },
            required=['full_name', 'email', 'password', 'confirm_password'],
        ),
        responses={
            200: openapi.Response(
                description='OTP sent successfully',
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'email': openapi.Schema(type=openapi.TYPE_STRING),
                    }
                )
            ),
            400: 'Bad request - missing fields, passwords don\'t match, or email already exists',
            500: 'Server error - failed to send email',
        }
    )
    def post(self, request):
        full_name = request.data.get("full_name", "").strip()
        email = request.data.get("email", "").strip()
        password = request.data.get("password", "")
        confirm_password = request.data.get("confirm_password", "")
        
        # Validate input
        if not full_name or not email or not password or not confirm_password:
            return Response({"error": "Full name, email, password and confirm password required"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate passwords match
        if password != confirm_password:
            return Response({"error": "Passwords do not match"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate password length
        if len(password) < 8:
            return Response({"error": "Password must be at least 8 characters long"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if user already exists
        if User.objects.filter(email=email).exists():
            return Response({"error": "Email already registered"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Generate OTP
        otp = ''.join(random.choices(string.digits, k=6))
        
        # Save or update OTP record with signup data
        otp_record, created = OTPVerification.objects.get_or_create(email=email)
        otp_record.otp = otp
        otp_record.is_verified = False
        otp_record.attempts = 0
        otp_record.full_name = full_name
        otp_record.password = password
        otp_record.save()
        
        # Send OTP via email
        try:
            subject = "OTP Verification for Signup"
            message = f"Your OTP for signup is: {otp}\n\nThis OTP will expire in 10 minutes."
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL or 'noreply@example.com',
                [email],
                fail_silently=False,
            )
            
        except Exception as e:
            return Response(
                {"error": "Failed to send OTP email", "details": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        return Response({
            "message": "OTP sent to your email",
            "email": email
        }, status=status.HTTP_200_OK)


class VerifyOTPView(views.APIView):
    """
    Verify OTP and complete user registration.
    
    After receiving OTP via email, user sends email and OTP to complete signup.
    """
    
    @swagger_auto_schema(
        operation_description="Verify OTP and complete signup",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
                'otp': openapi.Schema(type=openapi.TYPE_STRING, description='6-digit OTP'),
            },
            required=['email', 'otp'],
        ),
        responses={
            200: openapi.Response(
                description='OTP verified successfully, user created',
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'access': openapi.Schema(type=openapi.TYPE_STRING, description='JWT access token'),
                        'refresh': openapi.Schema(type=openapi.TYPE_STRING, description='JWT refresh token'),
                    }
                )
            ),
            400: 'Bad request - invalid OTP or email',
            401: 'OTP expired or incorrect',
            429: 'Too many attempts',
        }
    )
    def post(self, request):
        email = request.data.get("email", "").strip()
        otp = request.data.get("otp", "")
        
        # Validate input
        if not email or not otp:
            return Response({"error": "Email and OTP required"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Get OTP record
        try:
            otp_record = OTPVerification.objects.get(email=email)
        except OTPVerification.DoesNotExist:
            return Response({"error": "No OTP found for this email"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if OTP is expired
        if otp_record.is_expired():
            otp_record.delete()
            return Response({"error": "OTP has expired"}, status=status.HTTP_401_UNAUTHORIZED)
        
        # Check attempts
        if otp_record.attempts >= 3:
            otp_record.delete()
            return Response({"error": "Too many attempts. Please request a new OTP"}, status=status.HTTP_429_TOO_MANY_REQUESTS)
        
        # Verify OTP
        if otp_record.otp != otp:
            otp_record.attempts += 1
            otp_record.save()
            return Response({"error": "Invalid OTP"}, status=status.HTTP_401_UNAUTHORIZED)
        
        # Get signup data from OTP record
        full_name = otp_record.full_name
        password = otp_record.password
        
        if not full_name or not password:
            return Response({"error": "Signup data not found"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Create user
        try:
            user = User.objects.create_user(
                username=email,  # Use email as username
                email=email,
                password=password,
                first_name=full_name,
            )
            user.is_active = True
            user.save()
            
            # Mark OTP as verified and delete
            otp_record.is_verified = True
            otp_record.delete()
            
            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)
            access = refresh.access_token
            
            return Response({
                "message": "Account created successfully",
                "access": str(access),
                "refresh": str(refresh),
            }, status=status.HTTP_200_OK)
        
        except Exception as e:
            return Response(
                {"error": "Failed to create user", "details": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ResendOTPView(views.APIView):
    """
    Resend OTP to email if user didn't receive it.
    """
    
    @swagger_auto_schema(
        operation_description="Resend OTP to email",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
            },
            required=['email'],
        ),
        responses={
            200: 'OTP resent successfully',
            400: 'Email not found or invalid',
            500: 'Failed to send email',
        }
    )
    def post(self, request):
        email = request.data.get("email", "").strip()
        
        if not email:
            return Response({"error": "Email required"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Get OTP record
        try:
            otp_record = OTPVerification.objects.get(email=email)
        except OTPVerification.DoesNotExist:
            return Response({"error": "No signup request found for this email"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if already verified
        if otp_record.is_verified:
            return Response({"error": "Email already verified"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Reset attempts and generate new OTP
        otp = ''.join(random.choices(string.digits, k=6))
        otp_record.otp = otp
        otp_record.attempts = 0
        otp_record.save()
        
        # Send OTP via email
        try:
            subject = "OTP Verification for Signup (Resend)"
            message = f"Your OTP for signup is: {otp}\n\nThis OTP will expire in 10 minutes."
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL or 'noreply@example.com',
                [email],
                fail_silently=False,
            )
            # (debug print removed)
        except Exception as e:
            return Response(
                {"error": "Failed to send OTP email", "details": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        return Response({
            "message": "OTP resent to your email",
            "email": email
        }, status=status.HTTP_200_OK)
    
class GetCurrentUserView(views.APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        return Response({
            "id": user.id,
            "email": user.email,
            "full_name": user.first_name,  
            "username": user.username,
        })