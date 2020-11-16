# Rinder

## To run it:

- In your terminal `cd` into the project Repo
- If you haven't already, install Cocoapods with the command: `pod init`
- Run `pod install` regardless of if you had previously done step 1
- Open `Rinder.xcworkspace` for the code. Don't use `Rinder.xcodeproj`
- Run the project using the iPhone 12 simulator
- Click the play button to run it

## It wont run unless...
- You add your `GoogleService-Info.plist` file under Rinder>Rinder

![Directory for file](https://github.com/fprospato/Rinder/blob/main/Screen%20Shot%202020-11-15%20at%2012.46.07%20AM.png)

## Generating SwiftLint Report 
- Build the project as usual 
- After successful build, press the warning button in the upper left hand corner 

![Warning Button](https://github.com/fprospato/Rinder/blob/main/Warnings_Button.png)

- Click on the highlighted drop down menu and select Rinder 

![Menu](https://github.com/fprospato/Rinder/blob/main/DropDownMenu.png)

- Click the export button and save the build report as something like swift_lint_report.txt in your Rinder folder 

![Export](https://github.com/fprospato/Rinder/blob/main/Export.png)

- Open the exported report, remove all text except for the linting information, and save. You file should look something like the one below but the paths will be different

![SwiftLintReport](https://github.com/fprospato/Rinder/blob/main/SwiftLintReport.png)

- Move the report to the SwiftLintReports folder 


## Don't commit the Pods folder. 
Just commit anything u know u changed lol. Xcode sometimes shows random stuff that'll mess up the repo on our end if it's committed.
