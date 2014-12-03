CBToolkit
=========


CBToolkit is a collection of simple UI features for iOS. They are easily customizable and easy to implement. 


<img src="/CBToolkitVideo.gif">

<h1>CBButton</h1>

* Bouncy
* Pop When Selected 
* Damping
* Shrink Scale
* Pop Scale
* Corner Radius
* Border color/width


A highly customizable button that can be used with any UIView. Just change the class in IB to CBButton.

You can connect IBActions just like any UIButton to handle selection events. 

Turn bounce on/off or change the damping right in IB. You can also customize the popScale in IB. Generally, the bigger the view the closer shrinkScale and popScale should be to 1.



<h1>CBViews</h1>

* CBView - Rounded corners </br>
* CBShadowView - Shadow </br>
* CBBorderView - Optional borders for each side of a view with insets.

Add shadows or rounded corners to views right in IB. No more outlets just to adjust these simple settings. CBView gives your easy rounded corner capability and CBShadowView, shadows. Due to the need to clip to bounds for corner radius these are seperate type. For a RoundedView with a shadow embed CBView inside a CBShadowView.

CBBorderView can be used to put borders on specific sides of a view. (See the dark top border on composer area in the video.)


<h1>CBTextView</h1>

A very easy to use UITextView subclass that works like the Messages app. As text changes the height adjusts to fit the text. Your project should use autoLayout.

I recommend putting the textView in a UIView. Set the textView with the desired constraints to each side of the container. The container should have a given width or attached left and right to it's parent. Make sure the container does not define it's own height. 

Customizable Settings
* minimumHeight </br>
* maximumHeight </br>
* placeholderText </br>
* placeholderColor </br>
* normalTextColor </br>
* borderColor </br>
* cornerRadius

Note: to help your layouts in IB, set a height constraint on your textViews container view and select 'remove at runtime'.

Things to do
Better handle placeholder text. - If the place holder text is entered by the user it will get cleared on reFocus. 



