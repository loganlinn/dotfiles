(ns aerospace.main
  (:require
   [aerospace.core :as aerospace])
  (:gen-class))

(defn -main [& _]
  (prn (aerospace/config)))
