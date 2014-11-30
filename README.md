iOS-Utils
=========


iOS-Utils is a collection of simple UI features for iOS. They are easily customizable and easy to implement. 


BouncyButtonView

This is a simple take on UIButton with the flexibility to use any UIView. Set the class of a UIView in a storyboard or XIB to BouncyButtonView and it will react to touches. You can customize the shrink scale directly from the IB. 

Handing touches is done via completion blocks. Add onTouchUp and onTouchDown blocks as needed. 

The onTouchUp block must return a boolean to indicate if the button should Pop. This is good for things such as a like button to give some cool feedback. 

You can also customize the popScale in IB. Generally, the bigger the view the closer shrinkScale and popScale should be to 1.



ExpandingTextView

A very easy to use UITextView subclass that works like the Messages app. As text changes the height adjusts to fit the text. Your project should use autoLayout.

I recommend putting the textView in a UIView. Set the textView with the desired constraints to each side of the container. The container should have a given width or attached left and right to it's parent. Make sure the container does not define it's own height. 

Customizable Settings
• minimumHeight
• maximumHeight
• placeholderText
• placeholderColor
• normalTextColor
• borderColor
• cornerRadius



Note: to help your layouts in IB, set a height constraint on your textViews container view and select 'remove at runtime'.


Things to do
Better handle placeholder text. - If the place holder text is entered by the user it will get cleared on reFocus. 



