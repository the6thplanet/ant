# Version 1
from django.http import HttpResponse

def version1(request):
    return HttpResponse("Hello World Version 1")

