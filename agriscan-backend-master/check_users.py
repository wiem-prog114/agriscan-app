import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.models import User

users = User.objects.all()
print(f"Total users: {len(users)}")
for user in users:
    print(f"Username: {user.username}, Email: {user.email}, Active: {user.is_active}")
