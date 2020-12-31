//
//  SJCTabelManger.m
//  Yehwang
//
//  Created by Yehwang on 2020/12/21.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "SJCTabelManger.h"

static NSString *UITableViewCellID = @"UITableViewCell";

@implementation SJCTabelItem

+ (instancetype)modelWithRowHeight:(CGFloat )rowHeight
             cellForRowAtIndexPath:(cellSetup)cellForRowAtIndexPath
           didSelectRowAtIndexPath:(cellClickBlock)didSelectRowAtIndexPath {
    SJCTabelItem *row = [[SJCTabelItem alloc] init];
    row.rowHeight = rowHeight;
    row.cellForRowAtIndexPath = cellForRowAtIndexPath;
    row.didSelectRowAtIndexPath = didSelectRowAtIndexPath;
    return row;
}

- (instancetype)init {
    if (self=[super init]) {
        _rowHeight = .0f;
    }
    return self;
}

@end



@interface SJCTabelSection ()

@property (strong, readwrite, nonatomic) NSMutableArray <SJCTabelItem *>*mutableRows;

@end

@implementation SJCTabelSection

- (instancetype)init {
    self = [super init];
    if (self) {
        _headerHeight = .001f;
        _footerHeight = .001f;
        _viewForHeaderInSection = ^UIView * _Nullable(UITableView * _Nonnull tableView, NSInteger section) {
            return [UIView new];
        };
        _viewForFooterInSection = ^UIView * _Nullable(UITableView * _Nonnull tableView, NSInteger section) {
            return [UIView new];
        };
    }
    return self;
}

- (void)addRow:(SJCTabelItem *)row {
    if ([row isKindOfClass:[SJCTabelItem class]])
        ((SJCTabelItem *)row).section = self;
    NSAssert(row.cellForRowAtIndexPath, @"必须要实现cellForRowAtIndexPath");
    [self.mutableRows addObject:row];
}

- (void)addRowsFromArray:(NSArray <SJCTabelItem *>*)rows {
    for (SJCTabelItem *row in rows) {
        [self addRow:row];
    }
//    [self.rows addObjectsFromArray:rows];
}

- (void)addItemText:(NSString *)str {
    ////////需要先去注册registerDefaultClasses
    SJCTabelItem *item = [SJCTabelItem modelWithRowHeight:100 cellForRowAtIndexPath:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellID forIndexPath:indexPath];
        cell.textLabel.font = PoppinsMedium(18);
        cell.textLabel.textColor = UIColor.systemPinkColor;
        cell.textLabel.text = str;
        return cell;
    } didSelectRowAtIndexPath:^(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath) {
        
    }];
    
    [self addRow:item];
}

- (NSMutableArray <SJCTabelItem *>*)mutableRows {
    if (!_mutableRows) {
        _mutableRows = [NSMutableArray array];
    }
    return _mutableRows;
}

- (NSArray <SJCTabelItem *>*)rows {
    return self.mutableRows.copy;
}

- (void)dealloc {
    
}

@end



@interface SJCTabelManger ()

@property (strong, readwrite, nonatomic) NSMutableArray <SJCTabelSection *>*mutableSections;

@end

@implementation SJCTabelManger

+ (instancetype)mangerTableView:(UITableView *)tab {
    return [[self alloc] initWithTabelview:tab];
}

- (instancetype)initWithTabelview:(UITableView *)tab {
    if (self = [super init]) {
        tab.dataSource = self;
        tab.delegate = self;
        self.tableView = tab;
        [self registerDefaultClasses];
    }
    return self;
}

- (void)registerDefaultClasses {
    self[UITableViewCellID] = @"UITableViewCell";
//    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

//注册自定义的cell(xib的注册方法一样)
- (void)registerClass:(Class)objectClass forCellReuseIdentifier:(NSString *_Nullable)identifier {
    [self registerClass:objectClass forCellReuseIdentifier:identifier bundle:nil];
}

- (void)registerClass:(Class)objectClass forCellReuseIdentifier:(NSString *_Nullable)identifier bundle:(nullable NSBundle *)bundle {
    NSAssert(objectClass, ([NSString stringWithFormat:@"Cell '%@' does not exist.", objectClass]));
    NSAssert(identifier, ([NSString stringWithFormat:@"identifier '%@' does not exist.", identifier]));
    self.registeredClasses[(id <NSCopying>)objectClass] = objectClass;
    if (!bundle)
        bundle = [NSBundle mainBundle];
    //xib的名字需要和对应的类名一致
    if ([bundle pathForResource:NSStringFromClass(objectClass) ofType:@"nib"]) {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(objectClass) bundle:bundle] forCellReuseIdentifier:identifier];
    }else{
        [self.tableView registerClass:objectClass forCellReuseIdentifier:identifier];
    }
}

- (id)objectAtKeyedSubscript:(id <NSCopying>)key {
    return self.registeredClasses[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [self registerClass:NSClassFromString(obj) forCellReuseIdentifier:(NSString *)key];
}

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath {
    SJCTabelSection *section = self.mutableSections[indexPath.section];
    NSObject *item = section.rows[indexPath.row];
    return self.registeredClasses[item.class];
}

- (void)registerClass:(nullable Class)aClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier {
    NSBundle *bundle = [NSBundle mainBundle];
    //xib的名字需要和对应的类名一致
    if ([bundle pathForResource:NSStringFromClass(aClass) ofType:@"nib"]) {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(aClass) bundle:bundle] forHeaderFooterViewReuseIdentifier:identifier];
    }else{
        [self.tableView registerClass:aClass forHeaderFooterViewReuseIdentifier:identifier];
    }
}

- (void)addSection:(SJCTabelSection *)section {
    section.tableViewManager = self;
    [self.mutableSections addObject:section];
}

- (void)addSectionsFromArray:(NSArray <SJCTabelSection *>*)sections {
    [self.mutableSections addObjectsFromArray:sections];
}

- (void)reloadSectionsFromArray:(NSArray <SJCTabelSection *>*)sections {
    [self clear];
    [self addSectionsFromArray:sections];
}

- (void)clear {
    [self.mutableSections removeAllObjects];
}

- (NSMutableArray <SJCTabelSection *>*)mutableSections {
    if (!_mutableSections) {
        _mutableSections = [NSMutableArray array];
    }
    return _mutableSections;
}

- (NSArray <SJCTabelSection *>*)sections {
    return self.mutableSections.copy;
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section].rows[indexPath.row].rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section].rows[indexPath.row].cellForRowAtIndexPath(tableView, indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    !self.sections[indexPath.section].rows[indexPath.row].didSelectRowAtIndexPath? : self.sections[indexPath.section].rows[indexPath.row].didSelectRowAtIndexPath(tableView, indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.sections[section].headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.sections[section].footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sections[section].viewForHeaderInSection(tableView, section);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.sections[section].viewForFooterInSection(tableView, section);
}

- (nullable UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point  API_AVAILABLE(ios(13.0)){
    return self.sections[indexPath.section].rows[indexPath.row].contextMenuConfigurationForRowAtIndexPath? self.sections[indexPath.section].rows[indexPath.row].contextMenuConfigurationForRowAtIndexPath(tableView, indexPath,point) : nil;
}


@end
