import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.models import User

# Delete old testuser
User.objects.filter(username='testuser').delete()
print("Deleted old testuser")

# Create new testuser with proper email
user = User.objects.create_user(
    username='testuser',
    email='testuser@example.com',
    password='testpass123'
)
user.is_active = True
user.save()
print(f"Created new user: {user.username} with email: {user.email}")
