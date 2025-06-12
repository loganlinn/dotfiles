(ns aerospace.core
  (:require
   [cheshire.core :as json]
   [babashka.fs :as fs])
  (:import
   [org.tomlj Toml JsonOptions]))

(defn- load-toml [path]
  (-> path
      str
      slurp
      Toml/parse
      (.toJson (into-array JsonOptions []))
      json/parse-string))

(defn default-config-path []
  (fs/path (fs/xdg-config-home "aerospace") "aerospace.toml"))

(defn config
  [& {:keys [config-path]
      :or {config-path (default-config-path)}}]
  (load-toml config-path))
