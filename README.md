# SJCTabelManger
任意的管理你的UITableView，自定义列表，更改顺序无需更改UITableView的代理和数据源方法,自定义组头组尾，你可以扩展自己最常用的cell到SJCTabelManger中，然后在要使用的地方，一行代码就可以把定制的cell加到视图的任意位置(最适用与静态界面例如设置界面的快速的搭建，动态活动列表界面，不适用于翻页的，大量的，单一cell的列表视图)

# 使用方法
```objective-c
1. #import "SJCTabelManger.h"

2.@property (nonatomic, strong) SJCTabelManger *manger;

3.  //初始化
    self.manger = [SJCTabelManger mangerTableView:self.tableView];
    
    //注册自定义的cell
    self.manger[@"UITableViewCellID"] = @"UITableViewCell";
    
    //注册自定义cell的另一种方式，xib和class的注册方式相同。
    [self.manger registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    
    //创建一组
    SJCTabelSection *section = [SJCTabelSection new];
    section.headerHeight = 100;
    section.footerHeight = 50;
    //返回组头
    section.viewForHeaderInSection = ^UIView * _Nullable(UITableView * _Nonnull tableView, NSInteger section) {
        return headerView;
    };
    //返回组尾
    section.viewForFooterInSection = ^UIView * _Nullable(UITableView * _Nonnull tableView, NSInteger section) {
        return footerView;
    };
    
    //创建自定义的cell
    SJCTabelItem *row = [SJCTabelItem new];
    row.rowHeight = 80;
    //返回自定义的cell，必须实现
    row.cellForRowAtIndexPath = ^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID" forIndexPath:indexPath];
        return cell;
    };
    row.didSelectRowAtIndexPath = ^(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath) {
        
    };
    
    [section addRow:row];
    
    //目前自定义的一个cell，内部已注册，一句代码就可以添加到表格上
    [section addItemText:@"只有一段文字的cell"];
    
    //把这一组加到视图上
    [self.manger addSection:section];
    [self.manger reloadData];
