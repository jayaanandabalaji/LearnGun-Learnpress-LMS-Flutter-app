## Firebase Notification And Google Login

Firebase Notification And Google Login feature is integrated with Google Firebase service. You need to sign up on the Firebase website and create a new project. Then, add your app to your Firebase project to register app.

Create a new project.
![43](../images/43.jpg)

In the newly opened window enter the name of the project. And click **Continue**.
![44](../images/44.png)

Next, select Google Analytics account or create a new one. Click on the Create Project.
![45](../images/45.png)

Wait for the project to load.
![46](../images/46.png)

On the opened page select the app platform Android.
![47](../images/47.jpg)

Write the package name and click on the Register app.
![48](../images/48.png)

The config file will be generated. You need to download it and upload to the following folder: Android > App in the project Learngun App.
![49](../images/49.jpg)

You will be notified that the file with the same name already exists. You need to confirm that you want to replace it.

### Push Notification

Find the **Cloud Messaging** menu on the Firebase Dashboard.
![50](../images/50.png)

On the new page click on the **Send your first message** button.
![51](../images/51.png)

Fill in the required fields and click on **Next**.
Please note before sending the test message, first you need to set up your App in Android Studio and launch it on the virtual device.
![52](../images/52.png)

After that, select the name of the project.
![53](../images/53.png)

Then, fill the fields that left depending on your preferences and click Review.
![54](../images/54.png)

You will see the next window, just click Publish and you are set.
![55](../images/55.png)

### Google Login

Just go to authentication from Firebase menu and enable **Google Sign In** in **Sign In providers** and hit **save** and then google signin will be working on the  app.
![56](../images/56.png)

### Facebook Login

Follow **step 1,4 and 5** on [https://facebook.meedu.app/docs/4.x.x/android](https://facebook.meedu.app/docs/4.x.x/android)