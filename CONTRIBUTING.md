# Contributing to lab2hub

First and foremost, thank you! We appreciate that you want to contribute to this project, your time is valuable, and your contributions mean a lot to us.

## Important!

By contributing to this project, you:

* Agree that you have authored 100% of the content
* Agree that you have the necessary rights to the content
* Agree that you have received the necessary permissions from your employer to make the contributions (if applicable)
* Agree that the content you contribute may be provided under the Project license(s)
* Agree that, if you did not author 100% of the content, the appropriate licenses and copyrights have been added along with any other necessary attribution.


## What does "contributing" mean?

Creating an issue is the simplest form of contributing to a project. But there are many ways to contribute, including the following:

- Updating or correcting documentation
- Feature requests
- Bug reports

## Contribution suggestions
This is a list of suggested improvements for the project:
- I ([@mwebler](https://github.com/mwebler)) am quite new to Ruby, so, any suggestions to improve the overall quality of the code is welcome.
- Improve app performance: I am pretty sure there are ways to improve the performance of the app. One I can think about is to take a look into how to dispatch parallel requests to retrieve the issues and comments without blocking. If I was working with JavaScript I would use promises, so I think maybe is possible to use something like [promise.rb](https://github.com/lgierth/promise.rb).
- Add different configuration environments (development, test, production) for the app.
- Add integration/feature tests: maybe use capybara for some end-to-end testing of the app.
- Add more handlers to exit gracefully in case of errors in API calls. Also, add some tests for those cases (currently most of the tests cover just the happy path).
- Improve the UI (for sure the app could have a nicer look).
- Add option to create a new repository on Github instead of using an existing one.
- Add option to add some metadata about the original issue and comments to Github: link to issue, reporter, date opened, date closed, comment date, comment author name, ...
- Add support for issues attachments
- Add option for the user to specify a Github Enterprise host and a self hosted Gitlab host

---
> This guideline was forked from a template from https://github.com/generate/generate-contributing