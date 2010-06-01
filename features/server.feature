Feature: Running a Hudson Server
  As a hudson server administrator
  I want to be able to easily control a hudson server 
  In order to spend my time on how the process operates, not how to start stop and control it. 
  
  Scenario: Start a Hudson Server
    Given env variable $HOME set to project path "home"
      And "home/.hudson" folder is deleted
      And there is nothing listening on port 5001
      And there is nothing listening on port 5002
      And I cleanup any hudson processes with control port 5002
    When I run hudson server with arguments "-p 5001 -c 5002 -d --logfile=server.log"
    Then I should see a hudson server on port 5001
      And folder "home/.hudson/server" is created
      And folder "home/.hudson/server/javatmp" is created
    