//
//  AVCamPreviewView.h
//  Trill
//
//  Created by Anatoliy Dalekorey on 6/27/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@class AVCaptureSession;

@interface AVCamPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *session;

@end
