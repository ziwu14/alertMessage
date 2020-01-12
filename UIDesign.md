### LoginVC

> * username (<u>textfield</u> for number/email)
> * password (<u>textfield</u>)
> * signUpButton (<u>button</u> ---> SignupVC)
> * logInButton (<u>button</u> ---> MainActivityVC)
> * [Forget Password (<u>button</u> ---> PasswordResetVC) ]

### SignupVC

> * username (<u>textfield</u> for number/email)
> * password (<u>textfield</u>)
> * passwordConfirm(<u>textfield</u>)
> * email (<u>textfield</u> for email)
> * phone (<u>textfield</u> for number)
> * confirm (<u>button</u> ---> LoginVC )

### MainActivityVC

> * Tab1 @ LocationMapVC
> * Tab2 @ RiskMapVC
> * Tab3 @ FriendsVC
> * Tab4 @ PersonalProfileVC
> * waterMe (<u>button</u> ### raise a status "risky")
> * helpMe (<u>button</u> ### raise a status "emergent")

### LocationMapVC

> * currentMap (MapView)
> * personalLocation (?)
> * \[rescuerLocation](?)

### RiskMapVC

> * curerntMap (MapView)
> * personalLocation (?)

### FriendsVC (TableViewController)

> * cell @ Image(Image) Name (label)  status (label)
> * Edit
> * Delete
> * Add

### PersonalProfileVC

> * Image (ImageView)
> * Username (Label)    edit (button)
> * Email (label).   edit (button ---> pop up verification dialog)
> * phone (label).   edit (button.   ---> pop up verification dialog)



