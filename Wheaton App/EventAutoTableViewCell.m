//
//  EventAutoTableViewCell.m
//  Wheaton App
//
//  Created by Chris Anderson on 1/21/14.
//
//

#import "EventAutoTableViewCell.h"

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        10.0f

@interface EventAutoTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation EventAutoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.dateLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.dateLabel setNumberOfLines:1];
        [self.dateLabel setTextAlignment:NSTextAlignmentLeft];
        [self.dateLabel setTextColor:[UIColor blackColor]];
        
        self.bodyLabel = [[UILabel alloc] init];
        self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bodyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.bodyLabel setNumberOfLines:0];
        [self.bodyLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.bodyLabel];
        
        [self updateFonts];
    }
    
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) {
        return;
    }
    
    // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
    // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
    //      See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
    // self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
    
    [self.dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.dateLabel.topAnchor constraintEqualToAnchor:self.dateLabel.superview.topAnchor constant:kLabelVerticalInsets].active = YES;
    [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.dateLabel.superview.leadingAnchor constant:kLabelHorizontalInsets].active = YES;
    [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.dateLabel.superview.trailingAnchor constant:-kLabelHorizontalInsets].active = YES;
    
    [self.bodyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.bodyLabel.topAnchor constraintEqualToAnchor:self.dateLabel.bottomAnchor constant:0.0f].active = YES;
    [self.bodyLabel.leadingAnchor constraintEqualToAnchor:self.bodyLabel.superview.leadingAnchor constant:kLabelHorizontalInsets].active = YES;
    [self.bodyLabel.trailingAnchor constraintEqualToAnchor:self.bodyLabel.superview.trailingAnchor constant:-kLabelHorizontalInsets].active = YES;
    [self.bodyLabel.bottomAnchor constraintEqualToAnchor:self.bodyLabel.superview.bottomAnchor constant:-kLabelVerticalInsets].active = YES;
    
    self.didSetupConstraints = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bodyLabel.frame);
}

- (void)updateFonts
{
    self.dateLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.bodyLabel.font = [UIFont systemFontOfSize:15.0f];
}

@end
