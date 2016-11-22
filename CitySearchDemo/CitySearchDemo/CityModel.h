//
//  CityModel.h
//  CitySearchDemo
//
//  Created by 张峻鸣 on 2016/11/22.
//  Copyright © 2016年 张峻鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject
/** type */
@property (nonatomic,copy) NSString *type;
/** associationId */
@property (nonatomic,copy) NSString *associationId;
/** associationName */
@property (nonatomic,copy) NSString *associationName;
@end
