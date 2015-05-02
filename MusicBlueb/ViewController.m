//
//  ViewController.m
//  MusicBlueb
//
//  Created by Arthur Berman on 3/21/15.
//  Copyright (c) 2015 Arthur Berman. All rights reserved.
//

#import "ViewController.h"
#import "CoreAudioKit/CABTMIDICentralViewController.h"
@import CoreMIDI;
#import "CoreAudioKit/CABTMIDILocalPeripheralViewController.h"
#import "Source/MIKMIDI.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noteGet;

@end

@implementation ViewController
int curnote = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)configureCentral:(id)sender
{
    // central vc, allows transparent assignment of midi source as bluetooth input
    CABTMIDICentralViewController *vController = [CABTMIDICentralViewController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vController];
    
    // this will present a view controller as a popover in iPad and modal VC on iPhone
    vController.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction:)];
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popC = navController.popoverPresentationController;
    popC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popC.sourceRect = [sender frame];
    
    UIButton *button = (UIButton *)sender;
    popC.sourceView = button.superview;
    
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)print:(id)sender {                                      //sending outgoing midi messages to destination endpoints
    MIKMIDIDeviceManager *manager = [MIKMIDIDeviceManager sharedDeviceManager];
    NSArray *availableMIDIDevices = [manager availableDevices];                     //gets list of all available midi devices
    for (MIKMIDIDevice *device in availableMIDIDevices) {
        NSLog(@"name %@", device.name);
        for (MIKMIDIEntity *entity in device.entities) {
            NSLog(@"entities %@", entity.name);
            for (MIKMIDIDestinationEndpoint *destination in entity.destinations){
                NSError *error = nil;
                MIKMutableMIDINoteOnCommand *command = [[MIKMutableMIDINoteOnCommand alloc] init];          //note on command
                command.note = 60 + curnote++;              // setting specific properties for message, actual note value and
                command.velocity = 64;                      // volume
                NSLog(@"note %lu", command.note);
                NSArray *commands = [NSArray arrayWithObjects:command, nil];                   // NSArray of commands to send
                [manager sendCommands:commands toEndpoint:destination error:&error];           // sending commands
                NSLog(@"Destination");
                NSLog(@"help");
                
            }
        }
    }
}
- (IBAction)activateReceipt:(id)sender {                             //receiving incoming midi messages from source endpoints
    
    MIKMIDIDeviceManager *manager = [MIKMIDIDeviceManager sharedDeviceManager];
    NSArray *availableMIDIDevices = [manager availableDevices];
    for (MIKMIDIDevice *device in availableMIDIDevices) {
        NSLog(@"name %@", device.name);
        for (MIKMIDIEntity *entity in device.entities) {
            NSLog(@"entities %@", entity.name);
            for (MIKMIDISourceEndpoint *source in entity.sources){                                     // getting all sources
                NSError *error = nil;
                [MIKMIDIEndpointSynthesizer playerWithMIDISource:source];                         //plays message from source
                BOOL success = [manager connectInput:source error:&error eventHandler:^(MIKMIDISourceEndpoint *source, NSArray *commands) { // used to connect to an input/ source endpoint -- the success token eventually gets passed
                    // to the disconnect method
                    for (MIKMIDINoteOnCommand *command in commands) { // handler block
                        // Handle each command
                        
                        NSLog(@"%lu", (unsigned long)command.note);
                        _noteGet.text = [NSString stringWithFormat:@"%lu",command.note];
                    }
                }];
                if (!success) {
                    NSLog(@"Unable to connect to %@: %@", source, error);
                    // Handle the error
                }
            }
        }
    }
}
- (IBAction)configureLocalPeripheral:(UIButton *)sender {
    // local peripheral vc, allows transparent assignment of midi destination as bluetooth outlet
    CABTMIDILocalPeripheralViewController *vController = [[CABTMIDILocalPeripheralViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vController];
    
    // this will present a view controller as a popover in iPad and modal VC on iPhone
    vController.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction:)];
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popC = navController.popoverPresentationController;
    popC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popC.sourceRect = [sender frame];
    
    UIButton *button = (UIButton *)sender;
    popC.sourceView = button.superview;
    
    [self presentViewController:navController animated:YES completion:nil];
}

@end
