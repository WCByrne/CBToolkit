CBToolkit
=========


Meet your new UI. CBToolkit brings your UI to life and thanks to xCodes IB tools, you can do it without a single line of code. All the elements in the kit are designs to be drag and drop replacements for their UIKit ancestors.

<img src="/CBIconButton.gif">

<h2>Adding to your project</h2>
<b>Manual</b><br />
Download or clone the files and drop CBToolkit/CBToolkit into your project. Your good to go.

<b>CocoaPods</b><br />
CBToolkit is now available on cocoapods 
Add `pod 'CBToolkit', '~> 0.0'` to your podfile and run pod update.

<h2>Using the views</h2>
CBToolkit is designed to help you creat great UIs without extra code. Thanks to IBDesignables many visual effects can me set right in the storyboard. Simple drop the appropriate UIKit element (UIView, UIButton, UIImageView...) into your view controller and change the class to the CB- equivilent.

For example, to add a `CBProgressView` just drop in a UIVIew, open the attributes inspector in the right utilities panel and set the class to CBProgressView. The custom properties will now be available right along side the standard backgroundColor and such.

And if you really have the urge to type, you can always create CBToolkit views progamatically just like anything else. 


<h1>Docs</h1>
[View the full docs](https://github.com/WCByrne/CBToolkit/wiki)
<br />
[Example app video](https://www.youtube.com/watch?v=AZnW26m93jc)

An example app is included in the repository to show you how some examples of how you can use CBToolkit in your app.


<h1>Views</h1>

* `CBView` : Round those corners, add a border, event drop some shadow all from the storyboard/IB inspector.
* `CBBorderView`: Add borders to each side of a view as needed.
* `CBGradientView`: Draw a gradient as a background or an overlay with zero code.
* `CBImageView`: Style your imageViews and even load remote image with a url.

[More about views](https://github.com/WCByrne/CBToolkit/wiki/1.-Views)


<h1>Buttons</h1>

* `CBButton` : Give your buttons some style and bounce.
* `CBIconButton`: From the classic hamburder to arrows, this button render it's icon with seamless transition.
* `CBButtonView`: A custom UIControl so you can turn any view into a button. Ctrl drag to link it to you code.

[More about buttons](https://github.com/WCByrne/CBToolkit/wiki/2.-Buttons)

<h1>TextViews</h1>

* `CBTextField` : Style your text views without a single line. Make your fields stand out right in the storyboard.
* `CBTextView`: Let this textview take care of resizign to fit its text. You can also add a placholder

[More about textview](https://github.com/WCByrne/CBToolkit/wiki/3.-Text-Views)


<h1>Loaders</h1>

* `CBActivityIndicator` : A clean and customizable replacement for UIActivityIndicator
* `CBProgressView`: Downloading or uploading? Show the prgress in style.

[More about progress views](https://github.com/WCByrne/CBToolkit/wiki/4.-Loaders)

<h1>Collection View Layouts</h1>

* `CBCollectionViewLayout` : A full features layout with waterfall, aspect ratio sizing, drag and drop and more.
* `CBSliderCollectionViewLayout`: A simple full screen horizontal layout with autoscrolling.

[More about collection view layouts](https://github.com/WCByrne/CBToolkit/wiki/5.-CollectionView-Layouts)


<h1>Utils</h1>

* `CBPhotoFetcher` : A image fetching util for retrieving and caching iamges with a url.
* `CBDate` extension: A collection of helpful date function and formatters.
* `CBPhoneNumber`: Just initialize with a string, then format or call the number.

[More about Utils](https://github.com/WCByrne/CBToolkit/wiki/6.-Utils)

