Feature: Running a Jenkins Server
  As a jenkins server administrator
  I want to be able to easily control a jenkins server 
  In order to spend my time on how the process operates, not how to start stop and control it. 
  
  Scenario: Start a Jenkins Server (jenkins server)
    Given env variable $HOME set to project path "home"
      And "home/.jenkins" folder is deleted
      And there is nothing listening on port 5001
      And there is nothing listening on port 5002
      And I cleanup any jenkins processes with control port 5002
    When I run jenkins server with arguments "--port 5001 --control 5002 --daemon --logfile=server.log"
    Then I should see a jenkins server on port 5001
      And folder "home/.jenkins/server" is created
      And folder "home/.jenkins/server/javatmp" is created
    