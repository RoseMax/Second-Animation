#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.submitButton.backgroundColor = [UIColor greenColor];
    self.submitButton.layer.cornerRadius = 8.0;
    self.submitButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.submitButton.layer.borderWidth = 1.0;
    self.submitButton.layer.shadowOffset= CGSizeMake(1.25, 2.0);
    self.submitButton.layer.shadowOpacity = 0.125;
}

-(IBAction)infoSubmit:(id)sender{
    NSURLSessionConfiguration *config =[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"EC2URL"]];
    request.HTTPMethod =@"POST";
    NSString *stringData = [NSString stringWithFormat:@"username=%@&password=%@", self.userID.text, self.password.text];
    NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody =data;
    
    NSURLSessionUploadTask *uploadTask =[session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else{
            NSLog(@"Got Response");
            NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
            if ([responseString isEqualToString:@"Success"]) {
                NSLog(@"Success");
                dispatch_async(dispatch_get_main_queue(),^{
                    [self.userID removeFromSuperview];
                    [self.password removeFromSuperview];
                    [self.submitButton removeFromSuperview];
                    [self runGame];
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(),^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Login" message:@"Please Re-enter your Login Details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                      [alert show];
                });
            }
        }
    }];
    
    [uploadTask resume];
    
}

-(void)runGame{
    //stuff that moves
    
    CGRect ballFrame = CGRectMake(100.0, 100.0, 64.0, 64.0);
    CGRect paddleFrame = CGRectMake(75.0, 300.0, 128.0, 32.0);
    
    self.ballView = [[UIView alloc]initWithFrame:ballFrame];
    self.ballView.backgroundColor = [UIColor blueColor];
    self.ballView.layer.cornerRadius = 32.0;
    self.ballView.layer.borderColor = [UIColor blackColor].CGColor;
    self.ballView.layer.borderWidth = 2.0;
    self.ballView.layer.shadowOffset= CGSizeMake(2.5, 4.0);
    self.ballView.layer.shadowOpacity = 0.25     ;
    
    self.paddleView = [[UIView alloc]initWithFrame:paddleFrame];
    self.paddleView.backgroundColor = [UIColor greenColor];
    self.paddleView.layer.cornerRadius = 8.0;
    self.paddleView.layer.borderWidth = 2.0;
    self.paddleView.layer.borderColor = [UIColor blackColor].CGColor;
    self.paddleView.layer.shadowOffset = CGSizeMake(2.5, 4.0);
    self.paddleView.layer.shadowOpacity = 0.25;
    
    [self.view addSubview:self.ballView];
    [self.view addSubview:self.paddleView];
    
    //gesture stuff
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reset)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    [self.view addGestureRecognizer:tap];
    
    [self engine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)engine{
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    self.pusher = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pusher.pushDirection=CGVectorMake(0.5, 1.0);
    self.pusher.active = YES;
    [self.animator addBehavior:self.pusher];
    
    //Collision stuff
    self.collider = [[UICollisionBehavior alloc]initWithItems:@[self.ballView, self.paddleView]];
    self.collider.collisionDelegate = self;
    self.collider.collisionMode = UICollisionBehaviorModeEverything;
    self.collider.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collider];
    
    self.ballProperties = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ballView]];
    self.ballProperties.allowsRotation= NO;
    self.ballProperties.elasticity =1.0;
    self.ballProperties.friction = 0.0;
    self.ballProperties.resistance = 0.0;
    [self.animator addBehavior:self.ballProperties];
    
    self.paddleProperties =[[UIDynamicItemBehavior alloc]initWithItems:@[self.paddleView]];
    self.paddleProperties.allowsRotation = NO;
    self.paddleProperties.density = 1000.0;
    [self.animator addBehavior:self.paddleProperties];
    
    self.attacher = [[UIAttachmentBehavior alloc]initWithItem:self.paddleView attachedToAnchor:CGPointMake(CGRectGetMidX(self.paddleView.frame), CGRectGetMidY(self.paddleView.frame))];
    [self.animator addBehavior:self.attacher];
    
    
}


-(void)reset{
    [self.animator removeAllBehaviors];
    self.collider = nil;
    self.pusher = nil;
    self.ballProperties =nil;
    self.paddleProperties = nil;
    self.attacher = nil;
    self.ballView.frame = CGRectMake(100.0, 100.0, 64.0, 64.0);
    self.paddleView.frame =CGRectMake(75.0, 300.0, 128.0, 32.0);
    [self engine];
}
-(void)tapped:(UIGestureRecognizer*)gesture{
    self.attacher.anchorPoint = [gesture locationInView:self.view];
}


@end
