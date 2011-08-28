Feature: ./git-bug
  In order to begin work on a bug
  As a developer
  I want to be able to start a bug from the command line

  Background: A git repo for a project in Pivotal Tracker
    Given the following git repo:
      | Name                | Pivotal Tracker Api Token/Project Id    |
      | git_pivotal_tracker | aa0469780e3d7322b17ab19de416c874/217457 |

  Scenario: Begin Working on the Latest Bug
    When I run `git-bug` interactively
      And I type ""
      And I run `git branch`
    Then the output should contain "bug-17553879-sample_bug"

  Scenario: Begin Working on the Latest Bug in a Custom Topic Branch
    When I run `git-bug` interactively
      And I type "custom_topic_branch"
      And I run `git branch`
    Then the output should contain "bug-17553879-custom_topic_branch"
