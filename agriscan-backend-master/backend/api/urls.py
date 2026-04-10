from django.urls import path
from .views import LoginView, SignupView, VerifyOTPView, ResendOTPView, GetCurrentUserView

urlpatterns = [
    path("auth/login/", LoginView.as_view(), name="login"),
    path("auth/signup/", SignupView.as_view(), name="signup"),
    path("auth/verify-otp/", VerifyOTPView.as_view(), name="verify-otp"),
    path("auth/resend-otp/", ResendOTPView.as_view(), name="resend-otp"),
    path("auth/me/", GetCurrentUserView.as_view(), name="current-user"),
]