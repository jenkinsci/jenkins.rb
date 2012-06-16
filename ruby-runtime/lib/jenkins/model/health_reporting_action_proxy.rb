module Jenkins::Model
  class HealthReportingActionProxy
    include ActionProxy
    include Java.hudson.model.HealthReportingAction
    proxy_for Jenkins::Model::HealthReportingAction

    def getBuildHealth
      @object.build_health
    end
  end
end
