Feature: Getting Started
  In order to begin work on an unstarted Pivotal Tracker story
  As a developer
  I want to be able to start a new git branch for the latest unstarted Pivotal Tracker story from the command line

  Background: A git repo for a project in Pivotal Tracker
    Given the following git repo:
      | Name                | Pivotal Tracker Api Token/Project Id    |
      | git_pivotal_tracker | aa0469780e3d7322b17ab19de416c874/217457 |

  Scenario Outline: Begin Working on a Latest Unstarted Story
    When I run `<command>` interactively
      And I type ""
      And I run `git branch`
    Then the output should contain "<git-branch-name>"

    Examples:
      | command     | git-branch-name                 |
      | git-story   | feature-17553875-sample_feature |
      | git-feature | feature-17553875-sample_feature |
      | git-chore   | chore-17553885-sample_chore     |
      | git-bug     | bug-17553879-sample_bug         |

  Scenario Outline: Begin Working on the Latest Unstarted Story in a Custom Branch
    When I run `<command>` interactively
      And I type "<custom-git-branch-name>"
      And I run `git branch`
    Then the output should contain "<custom-git-branch-name>"

    Examples:
      | command     | custom-git-branch-name              |
      | git-story   | feature-17553875-custom_branch_name |
      | git-feature | feature-17553875-custom_branch_name |
      | git-chore   | chore-17553885-custom_branch_name   |
      | git-bug     | bug-17553879-custom_branch_name     |
