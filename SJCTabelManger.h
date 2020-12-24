//
//  SJCTabelManger.h
//  Yehwang
//
//  Created by Yehwang on 2020/12/21.
//  Copyright © 2020 Yehwang. All rights reserved.
//

/**
 对于经常变动的业务，改变cell顺序，动态配置自己的个性列表用SJCTabelManger管理tableView避免牵一发而动全身，避免经常去修改代理方法。借鉴于RETableViewManager，适用于一些表单界面，静态界面，数据不是很多的界面
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef UITableViewCell *_Nullable(^cellSetup)(UITableView *tableView, NSIndexPath *indexPath);
typedef void (^cellClickBlock)(UITableView *tableView, NSIndexPath *indexPath);

/// Cell
@class SJCTabelSection;
@interface SJCTabelItem : NSObject

@property(assign,nonatomic) CGFloat rowHeight;
@property (nonatomic, copy) cellSetup cellForRowAtIndexPath;
@property (nonatomic, copy) cellClickBlock didSelectRowAtIndexPath;

/// 在cell上拿到section的tableViewManager
@property (weak, readwrite, nonatomic) SJCTabelSection *section;

/// 快速初始化
/// @param rowHeight rowHeight
/// @param cellForRowAtIndexPath cellForRowAtIndexPath
/// @param didSelectRowAtIndexPath didSelectRowAtIndexPath
+ (instancetype)modelWithRowHeight:(CGFloat )rowHeight
             cellForRowAtIndexPath:(cellSetup)cellForRowAtIndexPath
           didSelectRowAtIndexPath:(cellClickBlock)didSelectRowAtIndexPath;

@end



typedef UIView *_Nullable(^headerSetup)(UITableView *tableView, NSInteger section);
typedef UIView *_Nullable(^footerSetup)(UITableView *tableView, NSInteger section);


/// Section
@class SJCTabelManger;

@interface SJCTabelSection : NSObject

@property(assign,nonatomic) CGFloat headerHeight;
@property(assign,nonatomic) CGFloat footerHeight;
@property (nonatomic, copy) headerSetup viewForHeaderInSection;
@property (nonatomic, copy) footerSetup viewForFooterInSection;
@property (strong, readonly, nonatomic) NSArray <SJCTabelItem *>*rows;
/// 在section上拿到tableViewManager
@property (weak, readwrite, nonatomic) SJCTabelManger *tableViewManager;

/// 向组里面添加一个cell
/// @param row row
- (void)addRow:(SJCTabelItem *)row;

/// 向组里面添加一组cell
/// @param rows rows
- (void)addRowsFromArray:(NSArray <SJCTabelItem *>*)rows;

/// 快速初始化一些常用的cell
/// @param str str 
- (void)addItemText:(NSString *)str;

@end



/// Manger
@interface SJCTabelManger : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, readonly, nonatomic) NSArray <SJCTabelSection *>*sections;
@property (weak, readwrite, nonatomic) UITableView *tableView;

@property (strong, readwrite, nonatomic) NSMutableDictionary *registeredClasses;

/// 类方法初始化
/// @param tab TableView
+ (instancetype)mangerTableView:(UITableView *)tab;

/// 对象方法初始化
/// @param tab TableView
- (instancetype)initWithTabelview:(UITableView *)tab;

/// 注册cell
/// @param objectClass cell类
/// @param identifier cell重用标志
- (void)registerClass:(Class)objectClass forCellReuseIdentifier:(NSString *_Nullable)identifier;

- (void)registerClass:(Class)objectClass forCellReuseIdentifier:(NSString *_Nullable)identifier bundle:(nullable NSBundle *)bundle;

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath;

/// 另一种方式注册cell，self[@"UITableViewCellID"] = @"UITableViewCell";
/// @param key key
- (id)objectAtKeyedSubscript:(id <NSCopying>)key;

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

/// 添加一组
/// @param section section
- (void)addSection:(SJCTabelSection *)section;

/// 批量添加组
/// @param sections sections
- (void)addSectionsFromArray:(NSArray <SJCTabelSection *>*)sections;

/// 清空并添加组
/// @param sections sections
- (void)reloadSectionsFromArray:(NSArray <SJCTabelSection *>*)sections;

/// 清空
- (void)clear;

/// 刷新
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
