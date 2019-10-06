from eve import Eve
from flask import render_template,request,redirect,url_for, session, escape
from eve.auth import BasicAuth
from eve.methods.get import get_internal
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from werkzeug import secure_filename
from bson import regex
from random import randint
import json,pathlib,hashlib
import requests,random,os
from datetime import datetime
import re
import smtplib
import math
import smtplib
from werkzeug import secure_filename
import reverse_geocoder as rg
from fastai.vision import *
import cv2
import numpy as np
import base64
from PIL import Image
from io import BytesIO
from math import radians, cos, sin, asin, sqrt
import herepy
import ast

port = 5000
host = '10.42.0.1'
#host = "127.0.0.1"
class MyBasicAuth(BasicAuth):
    def check_auth(self, username, password, allowed_roles, resource, method):
        return username == 'root' and password == '66224466'

app = Eve(__name__, auth=MyBasicAuth)
app.config['SESSION_TYPE'] = 'memcached'
app.config['SECRET_KEY'] = '5234124584324'

headers = {'Authorization': 'Basic cm9vdDo2NjIyNDQ2Ng==', 'Content-Type':'application/json'}

app.config['MONGO_HOST'] = '0.0.0.0'
app.config['MONGO_PORT'] = '27017'
app.config['MONGO_DBNAME'] = 'sahayak'
app.config['MONGO_USERNAME'] = 'root'
app.config['MONGO_PASSWORD'] = '66224466'


UPLOAD_FOLDER = "../static/uploads/"
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER



@app.route("/login", methods=['POST', 'GET'])
def login():

    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = app.data.driver.db.client['sahayak']
        try:
            loginuser = db.grievance_users.find_one({"$and": [{"$or":[{"user_email": username},{"user_phone": username}]}, {"user_password": password}]})
            print(str(loginuser))
            if loginuser['user_type']=='admin':
                print('\n\ntrue:')
                session['admin_area']=loginuser['user_area']
                session['admin_login'] = True
                grievance_all=list(db.grievance.find({'assigned_authority':loginuser['user_area']}))
                return redirect('/index')
            else:
                CONTEXT_msg = 'Entered Username and password do not match. Please Retry!'
                return render_template("loginpage.html",CONTEXT_msg=CONTEXT_msg)
        except Exception as e:
            print(e)
            return render_template('loginpage.html')
        grievance_all=list(db.grievance.find({'assigned_authority':session['admin_area']}))
        return render_template('problems.html',all=[grievance_all,session['admin_area']])
    else:
        CONTEXT_msg = ''
        return render_template("loginpage.html",CONTEXT_msg=CONTEXT_msg)
        

@app.route('/logout')
def logout():
    session['admin_login'] = False
    return redirect('/login')

@app.route('/upload')
def upload():
    return render_template('add.html')


@app.route('/hello/<send_mail>',methods=['GET', 'POST'])
def predict(send_mail="no"):
    db = app.data.driver.db.client['sahayak']
    send_mail_to = None
    grievance_all=list(db.grievance.find())

    for i in grievance_all:
        if 'grievance_type' not in i or i['grievance_type']=="unpredicted" :
                filename = str(i['grievance_id'][:5])
                x = open('base64.txt',"w+")
                x.write(i['image_link'])
                x.close()
                f = open('base64.txt', 'r')
                data = f.read()
                f.closed
                im = Image.open(BytesIO(base64.b64decode(data)))
                im.save(filename[:5]+'.jpeg', 'JPEG')
                pathh=str(filename[:5]) + ".jpeg"
                path=Path('./')
                classes=['garbage','pothole','sewage']
                #data = ImageDataBunch.from_folder(path, train=".", valid_pct=0.2,ds_tfms=get_transforms(), size=224, num_workers=4).normalize(imagenet_stats)
                data = ImageDataBunch.single_from_classes(path, classes, ds_tfms=get_transforms(), size=240).normalize(imagenet_stats)
                learn = cnn_learner(data, models.resnet101, metrics=error_rate)
                learn.load('phase1')
                img = open_image(pathh)
                pred_class,pred_idx,outputs = learn.predict(img)
                print(str(pred_class))
                if(str(pred_class) == "sewage"):
                    send_mail_to = "kunjshah45@gmail.com"
                if(str(pred_class) == "garbage"):
                    send_mail_to = "singroleketan@gmail.com"
                if(str(pred_class) == "pothole"):
                    send_mail_to = "ramsuthar305@gmail.com"
                all1 = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"grievance_type":str(pred_class)}})

                if send_mail=="yes":
                    
                    sendMail(send_mail_to,"New Grievance Received","Your department has received a grievance. Please check your portel for details.")
                return "smd"
 
def distance(lat1, lat2, lon1, lon2): 
    lon1 = radians(lon1) 
    lon2 = radians(lon2) 
    lat1 = radians(lat1) 
    lat2 = radians(lat2) 
       
    dlon = lon2 - lon1  
    dlat = lat2 - lat1 
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
  
    c = 2 * asin(sqrt(a))  
     
    r = 6371
       
    return(c * r)




@app.route('/uploader', methods=['GET', 'POST'])
def uploader():
    if request.method == 'POST':
        db = app.data.driver.db.client['sahayak']
        f = request.files['file']
        grievance_id = request.form['gid']
        user_id = request.form['user']
        type = request.form['type']
        latitude = request.form['latitude']
        longitude = request.form['longitude']
        f.save(os.path.join( app.config['/uploads'], secure_filename("uploads/"+f.filename) ))
        db.grievance.insert_one({"image_link":f.filename,
        "grievance_id":grievance_id,
        "user_id":user_id,
        "grievance_type":type,
        "area":"",
        "latitude":latitude,
        "longitude":longitude,
        "assigned_authority":"null",
        "assigned_date":str(datetime.now()),
        "status":"unsolved",
        "timestamp":str(datetime.now())
        })

        return 'db.grievance.find()'


@app.route('/records')
def records():
    db = app.data.driver.db.client['sahayak']
    all=list(db.grievance.find())
    return render_template('table.html',all=all)

@app.route('/reports')
def reports():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find())
    # year=set()
    # for i in grievance_all:
    #     year.add(str(i['_updated'].year)
    # total={}
    # for j in year:
    #     total[j]={'solved':0,'pending':0}
    
    # for k in grievance_all:
        
    #     if k['assigned_date'][4] in year:
    #         yr=k['assigned_date'][4]
          
    #         if k['status']=='solved':
    #             total[yr]['solved']+=1
    #         else:
    #             total[yr]['pending']+=1


    pothole = [0,0,0,0,0,0,0,0,0,0,0,0]
    sewage = [0,0,0,0,0,0,0,0,0,0,0,0]  #Total grievance reported
    garbage = [0,0,0,0,0,0,0,0,0,0,0,0]

    totalpothole = totalsewage = totalgarbage = 0   # Grievances reported 


    solved = [0,0,0,0,0,0,0,0,0,0,0,0]   # Solved vs Pending
    unsolved = [0,0,0,0,0,0,0,0,0,0,0,0]

    for i in grievance_all:
        if(i["grievance_type"]== "sewage"):
            #pothole.append(i["grievance_type"])
            date,time = i["assigned_date"].split(" ")
            year,month,day = date.split("-")
            sewage[int(month)-1] += 1
            totalsewage += 1

            
            
            if(i["status"] == "unsolved"):
                unsolved[int(month)-1] += 1
            else:
                solved[int(month)-1] += 1
                


        if(i["grievance_type"]== "pothole"):
            #pothole.append(i["grievance_type"])
            date,time = i["assigned_date"].split(" ")
            year,month,day = date.split("-")
            pothole[int(month)-1] += 1
            totalpothole += 1

            if(i["status"]== "unsolved"):
                unsolved[int(month)-1] += 1
            else:
                solved[int(month)-1] += 1


        if(i["grievance_type"]== "garbage"):
            #pothole.append(i["grievance_type"])
            date,time = i["assigned_date"].split(" ")
            year,month,day = date.split("-")
            garbage[int(month)-1] += 1
            totalgarbage += 1

            if(i["status"]== "unsolved"):
                unsolved[int(month)-1] += 1
            else:
                solved[int(month)-1] += 1


    # print("solved : ",solved,"unsolved : ",unsolved)
    # print("totalpotholes : ",totalpothole,"totalsewage : ",totalsewage,"totalgarbage : ",totalgarbage)
    # print("potholes : " ,pothole,"sewage : ",sewage,"garbage : ",garbage)


   


    return render_template('admin.html',garbage = garbage,seewage = sewage,pothole = pothole, solved = solved, unsolved = unsolved,totalsewage = totalsewage,totalgarbage = totalgarbage,totalpothole = totalpothole)



def getLocationDetails(latitude,longitude):
    latitude = float(latitude)
    longitude = float(longitude)
    # api = "AIzaSyCOkw95Uhnr5QLxP0A0sDbtGr-aI4MHeSo"
    # url = "https://maps.googleapis.com/maps/api/geocode/json?latlng={},{}&key={}".format(latitude,longitude,api)
    # print(url)
    # response = requests.get(url)
    # response = json.loads(response.text)
    # print(response['results'])
    # response = response['results'][0]['address_components'][1]['long_name']
    
    #url = "https://us1.locationiq.com/v1/reverse.php?key=ba6d9d5b67664b&lat={}&lon={}&format=json".format(latitude,longitude)
    #print(url)
    #response = requests.get(url)
    #response = json.loads(response.text)
    #response = response['address']['road']

    gp=herepy.GeocoderReverseApi('wWRTCQ8UwCm4mELqVFKh','YyS1iuR4G9SZ8vkUmDGrXg')
    response = gp.retrieve_addresses([latitude, longitude])
    response = str(response)
    response = ast.literal_eval(response)
    response = response["Response"]["View"][0]["Result"][0]["Location"]["Address"]["Label"]

    return response


@app.route('/bar')
def bar():
    pincode=[11,12,11,13,15,11,16,17]
    tmp=set(pincode)
    count=[]
    print(tmp)
    for i in tmp:
        print(pincode.count(i))
        count.append(pincode.count(i))
    tick_label = ['one', 'two', 'three', 'four', 'five','six']
    print(count)
    pincode=list(tmp)
    print(pincode)
    plt.bar(pincode,count, tick_label = tick_label,width = 0.8, color = ['red', 'green'])
    plt.xlabel('Problems')
    plt.ylabel('Area')
    plt.title('Pincode')
    #plt.savefig('/graphs'+str(datetime.now())+'.png')
    return 'hii'

@app.route("/index")
def index():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find())

    for i in grievance_all:
        print(i["area"])
        if i['area'] == "unpredicted":
            print("smd"*10)
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            print('\n\n\n\nres:',res)
            ass_array = {"virar":[19.4564,72.7925],
            "panvel":[18.9894, 73.1175],
            "ghatkopar":[19.0858, 72.9090],
            "dahisar":[19.2494, 72.8596],
            "mira road ":[19.2871, 72.8688]}
            list_distance = {}
            for x in ass_array:
                list_distance[x]=distance(latitude,ass_array[x][0],longitude,ass_array[x][1])
            print(list_distance)
            distance_min = min(list_distance,key=list_distance.get)
            update_authority = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"assigned_authority":distance_min}})
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})
        predict()
    return render_template('problems.html',all=grievance_all)
    
@app.route('/solve/<id1>')
def solve(id1):
    db = app.data.driver.db.client['sahayak']
    db.grievance.find_one_and_update({'grievance_id':id1},{'$set':{'status':'solved'}})
    return redirect('/index')


@app.route("/userspecific/<id>")
def userspecific(id):
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"user_id":id}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})


    return render_template('problems.html',all=grievance_all)


@app.route("/virar")
def virar():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"assigned_authority":"virar"}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"assigned_authority":'virar'}})

            grievance_all=list(db.grievance.find({"assigned_authority":"virar"}))
    return render_template('problems.html',all=grievance_all)

@app.route("/panvel")
def panvel():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"assigned_authority":"panvel"}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"assigned_authority":'panvel'}})
            
            grievance_all=list(db.grievance.find({"assigned_authority":"panvel"}))
    return render_template('problems.html',all=grievance_all)

@app.route("/ghatkopar")
def ghatkopar():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"assigned_authority":"ghatkopar"}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"assigned_authority":'ghatkopar'}})
            
            grievance_all=list(db.grievance.find({"assigned_authority":"ghatkopar"}))
    return render_template('problems.html',all=grievance_all)

@app.route("/dahisar")
def dahisar():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"assigned_authority":"dahisar"}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"assigned_authority":'dahisar'}})

            grievance_all=list(db.grievance.find({"assigned_authority":"dahisar"}))
    return render_template('problems.html',all=grievance_all)

@app.route("/mira road")
def miraroad():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"assigned_authority":"mira road"}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})

            grievance_all=list(db.grievance.find({"assigned_authority":"mira road"}))
    return render_template('problems.html',all=grievance_all)


@app.route("/sewage")
def sewage():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"grievance_type":"sewage"}))

    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})

            grievance_all=list(db.grievance.find({"grievance_type":"sewage"}))
    return render_template('problems.html',all=grievance_all)

@app.route("/garbage")
def garbage():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"grievance_type":"garbage"}))
    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})

            grievance_all=list(db.grievance.find({"grievance_type":"garbage"}))
    return render_template('problems.html',all=grievance_all)

@app.route("/potholes")
def potholes():
    db = app.data.driver.db.client['sahayak']
    grievance_all=list(db.grievance.find({"grievance_type":"pothole"}))


    for i in grievance_all:
        if 'area' not in i or i['area']=="unpredicted":
            longitude=float(i['longitude'])
            latitude=float(i['latitude'])
            res=getLocationDetails(latitude,longitude)
            update_location = db.grievance.find_one_and_update({'grievance_id':i["grievance_id"]},{'$set':{"area":res}})

            grievance_all=list(db.grievance.find({"grievance_type":"potholes"}))
    return render_template('problems.html',all=grievance_all)


def sendMail(to, subject, body):
	gmail_user = 'nibodheducare@gmail.com'
	gmail_password = '***************'

	sent_from = gmail_user
	to = "singroleketan@gmail.com"
	subject = subject
	body = body

	email_text = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (sent_from, to, subject, body)

	try:
		server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
		server.ehlo()
		server.login(gmail_user, gmail_password)
		server.sendmail(sent_from, to, email_text)
		server.close()

		print ('Email sent!')
		return 'Email sent!'
	except Exception as e:
		print ('Something went wrong...'+str(e))
		return 'Email not sent!'

if __name__ == '__main__':
    app.run(host=host, port=port, debug=True)
