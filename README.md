CBToolkit
=========


Meet your new UI. CBToolkit brings your UI to life and thanks to xCodes IB tools, you can do it without a single line of code. All the elements in the kit are designs to be drag and drop replacements for their UIKit ancestors.

<img src="/CBIconButton.gif">

<h2>Adding to your project</h2>
<b>Manual</b>
Download or clone the files and drop CBToolkit/CBToolkit into your project. Your good to go.

<b>CocoaPods</b>
CBToolkit is now available on cocoapods 

Add `pod 'CBToolkit', '~> 0.0' to your podfile and run pod update.

<h2>Using the views</h2>
CBToolkit is designed to help you creat great UIs without extra code. Thanks to IBDesignables many visual effects can me set right in the storyboard. Simple drop the appropriate UIKit element (UIView, UIButton, UIImageView...) into your view controller and change the class to the CB- equivilent.

For example, to add a `CBProgressView` just drop in a UIVIew, open the attributes inspector in the right utilities panel and set the class to CBProgressView. The custom properties will now be available right along side the standard backgroundColor and such.

And if you really have the urge to type, you can always create CBToolkit views progamatically just like anything else. 


<h1>CBView</h1>

Forget about writing the tedious layer.[attribute] code when you want to give your buttons a little style. Round those corners, add a border, event drop some shadow all from the storyboard/IB inspector.

* `cornerRadius` : Round the corners of the view to whatever radius you wish
* `circleCrop`: Let autolayout do the work, CornerRadius will be set to 50% anytime your view changes size
* `borderWidth`: Well, set the width of the border
* `borderColor`: And the color of the border
* `shadowColor`: Set the color of the layer shadow
* `shadowRadius`: Set the shadow radius
* `shadowOpacity`: Set the opacity of the shadow 
* `shadowOffset`: Translate the shadow relative to the view
* `shouldRasterize`: Rasterize the layer for better performance, screen scale is handled as well
* `useShadowPath`: For square views, useShadowPath greatly improves performace. corner radius is also taken into account.

For More information on any of these attributes, checkout the CALayer documentation

Because layer shadows require that the view NOT clip it's bounds, it can cause problems when you want say, rounded corners, or an image to be clipped. To do so, embed your view into another CBView and turn on the shadow for the parent. With the parent background set to clear, the shadow will only be applied to the child.


<h1>CBButton</h1>

Interactive and fun UIs are all the rage. They really do bring a new level of interaction to the screen. Just swap your UIButton's class out for CBButton and you're good to go. If you need to adjust the animations for a different feel, just make a few changes in the Attributes Instepctor.

To handle selections, do the same things you would wiht your UIButton. It's just a subclass!

* `bouncy`: Enable bouncy animation when the button is touched.
* `popWhenSelected`: If true, the popAnimation will run automatically when selected is set to true.
* `damping`: The spring damping to apply the bounce animation
* `shrinkScale`: The percentage to scale down towhen selected from the initial value (0-1)
* `popScale`: The percentage to scale up to when the popAnimation is run (1+)

* `cornerRadius` : Round the corners of the view to whatever radius you wish
* `circleCrop`: Let autolayout do the work, CornerRadius will be set to 50% anytime your view changes size
* `borderWidth`: Well, set the width of the border
* `borderColor`: And the color of the border

<h2>CBButtonView</h2>

Ever wanted a button with more than an image to the left and text to the right? Well here you go, CBButtonView. All the functionality of a UIButton with the subview of a UIView, plus the animation of CBButton. If you're in the storyboard, just drop a UIView in, add your views then drop your IBActions to the controller. 



<h1>CBImageView</h1>

Just a UIImage with some practical updates. You'll never use a UIImage again.

* `cornerRadius`: Round your images right from the storyboard.
* `circleCrop`: Let autolayout do the work, CornerRadius will be set to 50% anytime your view changes size
* `borderColor`: The color of the border
* `borderWidth`: The width of the border
* `tinted`: Render the image as a template image to use the built in tint color
* `placeholderImage`: Set an image to be used anytime the image property is set to nil.

* `loadImageAtURL:completion:`: Load a remote image into the image view in one line. A nil callback will automatically set the image to the imageView.


TODO: 
* Better placeholder support for scaling
* Automatic loading animaitions





<h1>Special CBViews</h1>
<h2>CBBorderView</h2>
Add borders to each side of a view as needed. 

* `leftBorder`, rightBorder, topBorder, bottomBorder: Turn each side on and off individually
* `borderColor`: The color of each side's border.
* `borderWidth`: The width for each side's border

<h2>CBGradientView</h2>
Draw a gradient as a background or an overlay with zero code.

* `topColor`: The first color in the gradient
* `middleColor`: The second color in the gradient
* `bottomColor`: The third color in the gradient

* `topLocation`: The percentage point of the top color from top to bottom
* `middleLocation`: The percentage point of the middle color from top to bottom
* `bottomLocation`: The percentage point of the bottom color from top to bottom

Note: when using a clear color with CBGradientView the color before the opacity is set will make a difference. So if your top color with white(alpha 1) and bottom is black(alpha 0), the middle will appear greyish.



<h1>CBCollectionViewLayout</h1>

CollectionViewLayouts have never been easier. This layout is column based which means you say how many columns and cells are placed in the appropriate one. It can be display items all the same size or as a "Pinterest" style layout.

To get started just call `var layout = CBCollectionViewLayout(myCollectionView)`. 

If you don't need to change the number of columns you can set `layout.columnCount = 2`. To change the column count per section or with screen rotations use the delegate method `collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int`

You can also set the `sectionInsets` and `minimumColumnSpacing` which will affect the width of each column.

With the itemWidth set by the column, you have 3 options to set the height of each item. They are used in the order here. So if aspectRatioForItemAtIndexPath is implemented it is used, else it checks the next one.
    
    1. aspectRatioForItemAtIndexPath (delegate)
    2. heightForItemAtIndexPath (delegate)
    3. layout.defaultItemHeight

The delegate method aspectRationForItemAtIndexPath scales the size of the cell to maintain that ratio while fitting within the caclulated column width.


<h1>CBSliderCollectionViewLayout</h1>

This CollectionViewLayout provide a simple way to make a horizontal sliding view. All you have to do is say how many cells, and return the cells as normal. Each cell is sized to match the collectionView and scrolling moves horizontal. You can optionally turn on autoScroll to automaticall move through each cell with a given delay. 

Note: If autoscroll is used, you must provide the current index to account for manual interaction with the collectionView. If the user scrolls the CV, the layout needs to know where they scrolled to. One place you can do this is shown below.

````
func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (collectionView.collectionViewLayout as! CBSliderCollectionViewLayout).currentIndex = indexPath.row
    }
````



<h1>CBTextField</h1>

Nothing to special here except great looking text fields.

* `hideCaret` : Hide the text caret while editing
* `textInset`: Inset the text to add padding
* `placeholderColor`: The color of the placeholder text
* `bottomBorder`: Draw a border on the bottom of the textField instead of the normal layer border using the borderWidth and borderColor.

* `cornerRadius` : Round the corners of the view to whatever radius you wish
* `borderWidth`: Well, set the width of the border
* `borderColor`: And the color of the border



<h1>CBTextView</h1>

A very easy to use UITextView subclass that works like the Messages app. As text changes the height adjusts to fit the text. Your project should use autoLayout.

I recommend putting the textView in a UIView. Set the textView with the desired constraints to each side of the container. The container should have a given width or attached left and right to it's parent. Make sure the container does not define it's own height. 

Customizable Settings
* `minimumHeight`: The minimum height of the textView
* `maximumHeight` The max height the textView should expand to
* `placeholderText`: Placeholder text that will be cleared on focus
* `placeholderColor`: The color of the placholder text if any
* `normalTextColor`: The color for normal text input (not the placeholder)
* `borderColor`: The color of the layer border
* `borderWidth`: The width of the layer border
* `cornerRadius`: the corner radius of the view
* `currentText` : Returns the text only if it is not equal to the placeholder

Note: to help your layouts in IB, set a height constraint on your textViews container view and select 'remove at runtime'.

Things to do
Better handle placeholder text.






<h1>CBDate (NSDate extention)</h1>

CBDate provides a number of helpful extensions to the standard NSDate class.

* `startOfDate:`: Returns a date for the beginning in the day for the given date (or now if nil)
* `endOfDay:`: Returns a date for the last second in the day for the given date (or now if nil)
* `startOfWeek:`: Returns a date for the beginning of the week for the given date (or now if nil)
* `endOfWeek:`: Returns a date for the last second in the week for the given date (or now if nil)
* `dateForNextHour:`: Returns a date for the next hour that will occur from the given date (or now if nil)

<b>Relativity</b>
* `isSameDayAsDate:`: Determine if two dates fall on the dame calendar day.
* `isToday:`: Detmine if the date is today
* `isYesterday:`: Determine if the date occured yesterday

<b>Formatting</b>
* `timeAgo:`: The time since the date occured in the appropriate duration (seconds, minutes, hours, days, weeks, years). ex. '34s', '18m', '1d', 2w
* `relativeTimeFromNow:`: The relative time from now in words. (ex. now, moments ago) See CBRelativeDateStyle for options
* `relativeDayFromNow:`: The relative day from now in words optionally including the time. (ex. today, tomorrow, Wednesday) See CBRelativeDateStyle for options
* `timeString`: The time in 12hr format including am/pm values




<h1>CBPhotoFetcher</h1>

Downloading images is no hassle. Just pass your url and get the image. `CBPhotoFetcher` handles multiple callbacks for the same URL, progress, and caching images. 

CBImageView uses CBPotoFetcher internally to load images

````
        var progressView = CBProgressView()
        ...
        var imgURL = "www.myWebsite.com/images/kitty"
        CBPhotoFetcher.sharedFetcher.fetchImageAtURL(imgURL, completion: { (image, error) -> Void in
            if image != nil {
                
            }
        }) { (progress) -> Void in
            progressView.setProgress(CGFloat(progress), animated: true)
            return
        }
````

TODO: Disk storage of images for caching between loads.

