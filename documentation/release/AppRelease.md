## App Release

After you tested your app, you can sign the app for release to Google Play.

> This manual aims to display all the key steps for generating a signed app bundle. Please follow this link for the more detailed guide: [https://developer.android.com/studio/publish/app-signing#sign-apk](https://developer.android.com/studio/publish/app-signing#sign-apk)

For this, you need to open Build > Generate Signed Bundle / APK…

![26](../images/26.png)

In the new window select Android App Bundle.

![27](../images/27.png)

After that, in a new opened window select the Key or create a new one.

![28](../images/28.png)

Here is an instruction on how to create a new Key. Click on the Create new. You will see the new window opened. Click on the folder icon in the right top corner.

![29](../images/29.png)

Select the folder where the Key will be stored.

Fill in the information (all fields).

![30](../images/30.png)

Next, check the Export encrypted key, if it is the update of the already uploaded app to the Google Play.

> Please find more information here: [https://developer.android.com/studio/publish/app-signing#enroll_existing](https://developer.android.com/studio/publish/app-signing#enroll_existing)

Now you need to select Release option and launch app building process.

![31](../images/31.png)

After that, Android Studio will notify you that app building process is finished (see the notification in the right bottom corner).

![32](../images/32.png)

By clicking on the Locate you will be redirected to the folder where the file is stored. Also, app bundle can be found here: Project folder > Android > App > Release

> The full guide describing how to upload the app to the Google Play Console can be found here: [https://developer.android.com/studio/publish/upload-bundle](https://developer.android.com/studio/publish/upload-bundle)