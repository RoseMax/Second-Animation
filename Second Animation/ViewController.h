#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollisionBehaviorDelegate>
@property (strong, nonatomic) UIView *ballView;
@property (strong, nonatomic) UIView *paddleView;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIDynamicItemBehavior *paddleProperties;
@property (nonatomic, strong) UIDynamicItemBehavior *ballProperties;
@property (nonatomic, strong) UIAttachmentBehavior *attacher;

@property(nonatomic, strong) IBOutlet UITextField *userID;
@property(nonatomic, strong) IBOutlet UITextField *password;
@property(nonatomic, strong) IBOutlet UIButton *submitButton;

-(IBAction)infoSubmit:(id)sender;

@end

