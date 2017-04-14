module Jenkins::Model
  class ProminentProjectActionProxy
    include ActionProxy
    include Java.hudson.model.ProminentProjectAction
    proxy_for Jenkins::Model::ProminentProjectAction
  end
end
