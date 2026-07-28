#!/usr/bin/env nu

def main [on?: string] {

  let ip = "192.168.188.69"
  let pin = "1234"
  
  let response = if $on != null {
    http get --full $"http://($ip)/fsapi/SET/netRemote.sys.power?pin=($pin)&value=($on)"
  } else {
    let r = http get --full $"http://($ip)/fsapi/GET/netRemote.play.info.name?pin=($pin)"
    if $r.status == 200 {
      let $stations = $r | get body.content.1.content.0.content
      if ($stations | is-empty) {
        print "---"
      } else {
        $stations | get $.0.content | print
      }
    }
    $r
  }
  
  if $response.status != 200 {
    print --stderr $"Request failed with status: ($response.status)\nBody:"
    print --stderr $response.body
  }
}
