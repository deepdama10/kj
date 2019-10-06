from django.db import models
import datetime
# Create your models here.

class problems(models.Model):
    id=models.AutoField(primary_key=True)
    timestamp=models.DateTimeField(default=datetime.datetime.now())
    ptype=models.CharField(max_length=20)
    reporter=models.CharField(max_length=100)
    status=models.BooleanField(default=False)
    department=models.CharField(max_length=50)