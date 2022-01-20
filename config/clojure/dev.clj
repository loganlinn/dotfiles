(ns dev
  "Invoked via load-file from ~/.clojure/deps.edn, this
  file looks at what tooling you have available on your
  classpath and starts a REPL."
  (:require [clojure.repl :refer :all]
            [clojure.string :as str]))

(def ^:dynamic *debug* (System/getenv "CLJ_DEBUG"))

(def ^:dynamic *info* (not (System/getenv "CLJ_QUIET")))

(defn debug
  "Print if *debug* (from DEBUG environment variable) is truthy."
  [& args]
  (when *debug* (apply println args)))

(defn info
  "print if *info* (from lein_silent environment variable) is truthy."
  [& args]
  (when *info* (apply println args)))

(defn warn
  "print to stderr if *info* is truthy."
  [& args]
  (when *info*
    (binding [*out* *err*]
      (apply println args))))

(defn -require
  [& args]
  (try
    (apply require args)
    (info "[✓]" (cons 'require args))
    true
    (catch Exception _
      (info "[✖]" (cons 'require args))
      nil)))

(defn setup-dynamic-classloader! []
  (try
    (let [cl (.getContextClassLoader (Thread/currentThread))]
      (.setContextClassLoader (Thread/currentThread) (clojure.lang.DynamicClassLoader. cl)))
    (catch Throwable t
      (warn "Unable to establish a DynamicClassLoader!")
      (warn (ex-message t)))))

(defn start-repl
  "Ensures we have a DynamicClassLoader, in case we want to use
  add-libs from the add-lib3 branch of clojure.tools.deps.alpha (to
  load new libraries at runtime).
  If Jedi Time is on the classpath, require it (so that Java Time
  objects will support datafy/nav).
  Attempts to start a Socket REPL server. The port is selected from:
  * SOCKET_REPL_PORT environment variable if present, else
  * socket-repl-port JVM property if present, else
  * .socket-repl-port file if present, else
  * defaults to 0 (which will automatically pick an available port)
  Writes the selected port back to .socket-repl-port for next time.
  Then pick a REPL as follows:
  * if Figwheel Main is on the classpath then start that, else
  * if Rebel Readline is on the classpath then start that, else
  * start a plain ol' Clojure REPL."
  []
  (setup-dynamic-classloader!)

  (-require 'jedi-time.core)
  (-require '[fipp.edn :refer [pprint dbg] :rename {pprint fipp}])

  ;; socket repl handling:
  (let [->long #(try (and % (Long/parseLong %)) (catch Throwable _))
        s-port (or (->long (System/getenv "SOCKET_REPL_PORT"))
                   (->long (System/getProperty "socket-repl-port"))
                   (->long (try (slurp ".socket-repl-port") (catch Throwable _)))
                   0)]
    ;; if there is already a 'repl' Socket REPL open, don't open another:
    (when (resolve 'requiring-resolve)
      (when-not (get (deref (requiring-resolve 'clojure.core.server/servers)) "repl")
        (try
          (let [server-name (str "REPL-" s-port)]
            ((requiring-resolve 'clojure.core.server/start-server)
             {:port s-port :name server-name
              :accept 'clojure.core.server/repl})
            (let [s-port' (.getLocalPort
                           (get-in @(requiring-resolve 'clojure.core.server/servers)
                                   [server-name :socket]))]
              (info "Selected port" s-port' "for the Socket REPL...")
              ;; write the actual port we selected (for Chlorine/Clover to read):
              (spit ".socket-repl-port" (str s-port'))))
          (catch Throwable t
            (warn "Unable to start the Socket REPL on port" s-port)
            (warn (ex-message t)))))))
  ;; if Portal and clojure.tools.logging are both present,
  ;; cause all (successful) logging to also be tap>'d:
  (when (-require 'portal.console '[portal.api :as portal])
    ;; ...then install a tap> ahead of tools.logging:
    (when (-require 'clojure.tools.logging)
      (let [log-star (requiring-resolve 'clojure.tools.logging/log*)
            log*-fn  (deref log-star)]
        (alter-var-root
          log-star
          (constantly
            (fn [logger level throwable message]
              (try
                (let [^StackTraceElement frame (nth (.getStackTrace (Throwable. "")) 2)
                      class-name (symbol (demunge (.getClassName frame)))]
                  ;; only called for enabled log levels:
                  (tap>
                    {:form     '()
                     :level    level
                     :result   (or throwable message)
                     :ns       (symbol (or (namespace class-name)
                                           ;; fully-qualified classname - strip class:
                                           (str/replace (name class-name) #"\.[^\.]*$" "")))
                     :file     (.getFileName frame)
                     :line     (.getLineNumber frame)
                     :column   0
                     :time     (java.util.Date.)
                     :runtime  :clj}))
                (catch Throwable _))
              (log*-fn logger level throwable message))))))
    (info "Use (portal/open) to open new inspector"))
  ;; select and start a main REPL:
  (let [[repl-name repl-fn]
        (or (try
              (let [figgy (requiring-resolve 'figwheel.main/-main)]
                ["Figwheel Main" #(figgy "-b" "dev" "-r")])
              (catch Throwable _))
            (try ["Rebel Readline" (requiring-resolve 'rebel-readline.main/-main)]
                 (catch Throwable _))
            ["clojure.main" (resolve 'clojure.main/main)])]
    (info "Starting" repl-name "as the REPL...")
    (repl-fn)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tap>

; (defn queue [& args] (into (clojure.lang.PersistentQueue/EMPTY) args))
;
; (defn bounded-conj
  ; [^long n coll x]
  ; (let [b (== (count coll) n)]
    ; (cond-> (conj coll x)
      ; b pop)))
;
; (def taps-queue-size (atom 16))
;
; (def taps-queue (atom (queue)))
;
; (defn set-taps-queue-size! [n] (reset! taps-queue-size n))
;
; (defn reset-taps-queue! [] (reset! taps-queue (queue)))
;
; (defn qtap! [x] (swap! taps-queue #(bounded-conj @taps-queue-size % x)))
;
; (defn register-tap! [] (add-tap qtap!))
;
; (defn deregister-tap! [] (remove-tap qtap!))
;
; (defn view-taps [] (reverse (deref taps-queue)))
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(info (str "Loading: '" *file* "'..."))
(when-not (resolve 'requiring-resolve)
  (warn "warning: symbol not found: 'requiring-resolve'. "
        "Please use least Clojure 1.10+"))

(start-repl)
;; ensure a smooth exit after the REPL is closed
(System/exit 0)
