from django.core.management.base import BaseCommand
from django.contrib.auth.models import User

class Command(BaseCommand):
    help = 'Create a test user for API testing'

    def handle(self, *args, **options):
        username = 'testuser'
        email = 'testuser@example.com'
        password = 'testpass123'
        
        if User.objects.filter(username=username).exists():
            self.stdout.write(self.style.WARNING(f'User {username} already exists'))
        else:
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password
            )
            user.is_active = True
            user.save()
            self.stdout.write(
                self.style.SUCCESS(
                    f'Test user created successfully!\n'
                    f'Username: {username}\n'
                    f'Email: {email}\n'
                    f'Password: {password}'
                )
            )
