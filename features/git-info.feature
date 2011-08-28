Feature: ./git-info
  In order to determine what I'm working on
  As a developer
  I want to be able to view the Pivotal Tracker story associated with my current topic branch

  Background: A git repo for a project in Pivotal Tracker
    Given the following git repo:
      | Name                | Pivotal Tracker Api Token/Project Id    |
      | git_pivotal_tracker | aa0469780e3d7322b17ab19de416c874/217457 |

  @announce-stdout
  Scenario: View the Pivotal Tracker Story for the Current Topic Branch
    When I run `git-story` interactively
      And I type ""
      And I run `git-info`
    Then the output should contain "feature-17553875-sample_feature"
