from django.shortcuts import render,redirect
from .models import problems as p 
from .models import*
# Create your views here.

def home(request):
    list_of_sums=[0,0,0,0]
    garbage = p.objects.filter(ptype="garbage")
    pothole = p.objects.filter(ptype="potholes")
    sanitation = p.objects.filter(ptype="sanitation")
    sewage = p.objects.filter(ptype="sewage")
    list_of_types=[garbage,pothole,sanitation,sewage]
    for ptype in list_of_types:
        for item in ptype:
            if(item.ptype == 'garbage'):
                list_of_sums[0]=list_of_sums[0]+1
            elif(item.ptype == 'potholes'):
                list_of_sums[1]==list_of_sums[1]+1    
            elif(item.ptype == 'sewage'):
                list_of_sums[2]=list_of_sums[2]+1
            elif(item.ptype == 'sanitation'):
                list_of_sums[3]=list_of_sums[3]+1   
    total=list_of_sums[0]+list_of_sums[1]+list_of_sums[2]+list_of_sums[3]        
    

    dict = {'garbage':(list_of_sums[0]/total)*100,'pothole':(list_of_sums[1]/total)*100,'sewage':(list_of_sums[2]/total)*100,'sanitation':(list_of_sums[3]/total)*100}
    return render(request,'index.html',dict)

def upload(request):
    if request.method=='POST':
        data=request.POST
        typ=data['type']
        rep=data['reporter']
        dep=data['dept']
        print(typ,rep,dep)
        obj=problems(ptype=typ,reporter=rep,department=dep)
        obj.save()
    return redirect('/')