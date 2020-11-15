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

- You erase this Build Phase script. This script invokes Swiftlint, and it works, but it does not ignore the podfiles at the moment (working on it), so it will make your build fail. It should invoke 400+ warnings and 25 errors. Add it back later, dont forget the `Output Files` field.

![Swiftlint script](https://github.com/fprospato/Rinder/blob/main/Screen%20Shot%202020-11-15%20at%2012.35.43%20AM.png)

## Don't commit the Pods folder. 
Just commit anything u know u changed lol. Xcode sometimes shows random stuff that'll mess up the repo on our end if it's committed.
