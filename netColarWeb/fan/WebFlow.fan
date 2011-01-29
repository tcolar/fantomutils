// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 17, 2010 thibautc Creation
//

**
** WebFlow
**
class WebFlow
{
	WebFlowCtrl[] controllers

	WebStep? global404Ctrl
	WebStep? globalErrorCtrl
	WebStep? globalForbiddenCtrl
	Str? globalTemplateRoot
	Str? globalExtension

	WebStep[] steps
}

class WebStep
{
	Str path
	WebAction[] actions // can be WebCtrl, WebPageAction
}

mixin WebAction
{
}

class CtrlPack
{
	CallCtrlAction[] actions
}

class CallCtrlAction : WebAction
{
	Type actionClass // make this an action mixin / abstract class
}

class CallCtrlPackAction : WebAction
{
	CtrlPack ctrlPack // make this an action mixin / abstract class
}

class RenderPageAction : WebAction
{
	Str pagePath
	CallCtrlAction? controller // optional, none for "plain" page
}

class ProcessFormAction : WebAction
{
	WebAction formAction
	Str formName
}

class ContinueToAction
{
	Str path
}

class RedirecToAction
{
	Str path
}
