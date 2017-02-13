module Jenkins::Model
  class UnprotectedRootActionProxy
    include ActionProxy
    include Java.hudson.model.UnprotectedRootAction
    proxy_for Jenkins::Model::UnprotectedRootAction
  end
end
