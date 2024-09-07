default: all

all: system dirs invocation source just justfile

@system: \
  (pr 'arch' arch()) \
  (pr 'os' os()) \
  (pr 'os_family' os_family()) \
  (pr 'num_cpus' num_cpus())
  echo

@dirs: \
    (pr 'cache_dir' cache_dir()) \
    (pr 'config_dir' config_dir()) \
    (pr 'config_local_dir' config_local_dir()) \
    (pr 'data_dir' data_dir()) \
    (pr 'data_local_dir' data_local_dir()) \
    (pr 'executable_dir' executable_dir()) \
    (pr 'home_dir' home_dir())
    echo

@invocation: \
  (pr 'invocation_dir' invocation_dir()) \
  (pr 'invocation_dir_native' invocation_dir_native())
  echo

@source: \
  (pr 'source_file' source_file()) \
  (pr 'source_dir' source_dir())
  echo

@just: \
  (pr 'just_executable' just_executable()) \
  (pr 'just_pid' just_pid())
  echo

@justfile: \
  (pr 'justfile' justfile()) \
  (pr 'justfile_dir' justfile_dir())
  echo

@env *args:
  printenv {{ args }}
  echo

[private]
@pr name value:
  printf '%s=%q\n' {{ quote(name) }} {{ quote(value) }}
