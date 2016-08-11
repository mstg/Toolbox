/*
* @Author: mustafa
* @Date:   2016-08-10 06:37:52
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 08:22:33
*/

@interface ToolboxListModulesView : UIScrollView {
  NSMutableArray *_tagRegister;
}
-(ToolboxListModulesView*)initWithFrame:(CGRect)frame tbview:(UIScrollView*)tbview;
@end