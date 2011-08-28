Feature: ./git-chore
  In order to begin work on a chore
  As a developer
  I want to be able to start a chore from the command line

  Background: A git repo for a project in Pivotal Tracker
    Given the following git repo:
      | Name                | Pivotal Tracker Api Token/Project Id    |
      | git_pivotal_tracker | aa0469780e3d7322b17ab19de416c874/217457 |

  Scenario: Begin Working on the Latest Chore
    When I run `git-chore` interactively
      And I type ""
      And I run `git branch`
    Then the output should contain "chore-17553885-sample_chore"

  Scenario: Begin Working on the Latest Chore in a Custom Topic Branch
    When I run `git-chore` interactively
      And I type "custom_topic_branch"
      And I run `git branch`
    Then the output should contain "chore-17553885-custom_topic_branch"
