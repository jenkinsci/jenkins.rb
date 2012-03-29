module Jenkins::Model
  class RootActionProxy
    include ActionProxy
    include Java.hudson.model.RootAction
    proxy_for Jenkins::Model::RootAction
  end
end
