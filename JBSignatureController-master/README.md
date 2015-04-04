Features
========

* Presents the user with a fully customizeable view for them to sign
* Supports portrait and horizontal layout
* Returns a UIImage of the signature, optionally cropped and centered to fit
* Example shows how to save signature to a PNG file
* Code is well-documented allowing for easy customization
* Uses ARC
* Free!


Usage
=====

The code is well-documented so you should be able to tell what's going on rather quickly. There are two components: a `UIViewController` subclass that houses the protocol and handles events, and a `UIView` subclass that handles the touch events to draw the user's signature and return it as an image. You only need to work with the `UIViewController` subclass directly.

1. Add the files contained in the JBSignatureControllerSource directory to your project.
2. Design your "signature pad" background images and overwrite the default images.
3. Initialize the JBSignatureController class:

```
JBSignatureController *signatureController = [[JBSignatureController alloc] init];
signatureController.delegate = self;
[self presentModalViewController:signatureController animated:YES];
```
    
Note: although shown as a modal view controller here, you're not limited to that use case. You could just as easily push the view controller onto a navigation stack.
    
Protocol Implementation
=======================

The `JBSignatureControllerDelegate` protocol should be implemented to retrieve the signature from the controller and also to dismiss the view controller once the user has indicated that they're finished signing. The following protocol definitions are available:

Called when the user clicks the confirm button (required):<br>
`-(void)signatureConfirmed:(UIImage *)signatureImage signatureController:(JBSignatureController *)sender;`
       
Called when the user clicks the cancel button (optional):<br>
`-(void)signatureCancelled:(JBSignatureController *)sender;`
    
Called when the user clears their signature or when clearSignature is called. (optional):<br>
`-(void)signatureCleared:(UIImage *)clearedSignatureImage signatureController:(JBSignatureController *)sender;`
    

Example
=======

A working example is provided in the project's source.


License
=======

MIT/X11 Open Source License


Contributing
============

1. Fork it!
2. Make your changes in a new branch
3. Submit a pull request