{ config, lib, ... }:

with lib;

# https://docs.frigate.video/configuration/camera_specific/#reolink-cameras
let
  reolinkCameraType = types.submodule ({ config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
      };
      hostname = mkOption {
        type = types.str;
        default = "${config.name}.lan";
      };
      username = mkOption {
        type = types.str;
      };
      password = mkOption {
        type = types.str;
      };
      rtmpPort = mkOption {
        type = types.port;
        default = 1935;
      };

    };
  });

  cam1 = {
    rtmpPort = 1935;
    hostname = "192.168.44.99"; # "cam1.lan";
    username = "frigate";
    password = "frigate"; # TODO: use secrets
  };
in
{
  options = {
    modules.frigate = {
      reolinkCameras = mkOption {
        type = types.attrsOf reolinkCameraType;
        default = { };
      };
    };
  };

  config = {
    services.go2rtc = {
      enable = true;
      settings = {
        log.level = "debug";
        api.listen = "127.0.0.1:1984";
        rtsp.listen = "127.0.0.1:8554";
        streams = {
          cam1_main = "ffmpeg:http://${cam1.hostname}/flv?port=${toString cam1.rtmpPort}&app=bcs&stream=channel0_main.bcs&user=${cam1.username}&password=${lib.escapeURL cam1.password}#video=copy#audio=copy#audio=opus";
          cam1_sub = "ffmpeg:http://${cam1.hostname}/flv?port=${toString cam1.rtmpPort}&app=bcs&stream=channel0_sub.bcs&user=${cam1.username}&password=${lib.escapeURL cam1.password}#video=copy";
        };
      };
    };
    services.frigate = {
      hostname = mkDefault "${config.networking.hostName}.lan";
      settings = {
        logger.default = "debug";
        ffmpeg.hwaccel_args = "preset-rpi-64-h264";
        cameras = {
          #   rtsp_cam1 = {
          #     enabled = true;
          #     ffmpeg = {
          #       output_args = {
          #         record = ["preset-record-generic-audio-copy"];
          #       };
          #       input_args = ["preset-http-reolink"];
          #       inputs = [
          #         {
          #           path = "rtsp://${cam1.username}:${cam1.password}@${cam1.hostname}/Preview_01_main";
          #           input_args = ["preset-http-reolink"];
          #           roles = ["record"];
          #         }
          #         {
          #           path = "rtsp://${cam1.username}:${cam1.password}@${cam1.hostname}/Preview_01_sub";
          #           input_args = ["preset-rtsp-restream"];
          #           roles = ["detect"];
          #         }
          #       ];
          #     };
          #   };
          cam1 = {
            enabled = true;
            ffmpeg = {
              input_args = "preset-http-reolink";
              inputs = [
                {
                  # path = "rtsp://${config.services.go2rtc.settings.rtsp.listen}/cam1_main";
                  path = "http://${cam1.hostname}/flv?port=${toString cam1.rtmpPort}&app=bcs&stream=channel0_main.bcs&user=${cam1.username}&password=${lib.escapeURL cam1.password}#video=copy#audio=copy#audio=opus";
                  # input_args = [ "preset-rtsp-restream" ];
                  roles = [ "record" ];
                }
                {
                  # path = "rtsp://${config.services.go2rtc.settings.rtsp.listen}/cam1_sub";
                  path = "http://${cam1.hostname}/flv?port=${toString cam1.rtmpPort}&app=bcs&stream=channel0_sub.bcs&user=${cam1.username}&password=${lib.escapeURL cam1.password}#video=copy";
                  # input_args = [ "preset-rtsp-restream" ];
                  roles = [ "detect" ];
                }
              ];
            };
            # detect = {
            #   enabled = true;
            #   width = 640;
            #   height = 360;
            #   fps = 10;
            # };
            # objects = {
            #   track = [ "person" ];
            #   filters = {
            #     person = {
            #       threshold = 0.6;
            #     };
            #     dog = {
            #       threshold = 0.6;
            #     };
            #   };
            # };
            # live = {
            #   stream_name = "cam1_sub";
            #   height = 360;
            #   quality = 8;
            # };
            # enabled: True
            # ffmpeg:
            #   inputs:
            #     # Stream Low Res
            #     - path: http://192.168.xxx.xxx/flv?port=1935&app=bcs&stream=channel0_sub.bcs&user=NAME&password=MYPW
            #       roles:
            #         - detect
            #     # Stream High Res
            #     - path: http://192.168.xxx.xxx/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=NAME&password=MYPW
            #       roles:
            #         - record
            #   input_args: preset-http-reolink

            # detect:
            #   width: 640
            #   height: 360
            #   fps: 10
            #   enabled: True

            # objects:
            #   track:
            #     - person
            #   filters:
            #     person:
            #       threshold: 0.6
            #     dog:
            #       threshold: 0.6


            # live:
            #   stream_name: front_sub
            #   height: 360
            #   quality: 8
          };
          # mqtt = {
          #   enabled = mkDefault true;
          #   host = mkDefault "mqtt.${config.networking.hostName}.lan";
          # };
        };
      };
    };
  };
}
