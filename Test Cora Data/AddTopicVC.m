//
//  AddTopicVC.m
//  Test Cora Data
//
//  Created by Vojtěch Šťavík on 05/01/14.
//  Copyright (c) 2014 VojtechStavik.cz. All rights reserved.
//

#import "AddTopicVC.h"

@interface AddTopicVC ()

@property (strong, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (strong, nonatomic) IBOutlet UITextField *name;

@end

@implementation AddTopicVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void) done: (id) sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if (![self.name.text isEqualToString:@""]) {

        [self.delegate addNewTopicWithName:self.name.text initialTweetCount:[self.tweetCountLabel.text intValue]];
    
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
 
    [textField resignFirstResponder];
    
    return NO;

}

- (IBAction)sliderChanged:(id)sender {
    
    UISlider* slider = (UISlider *)sender;
    
    self.tweetCountLabel.text = [NSString stringWithFormat:@"%i",[[NSNumber numberWithFloat:slider.value] integerValue]];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
