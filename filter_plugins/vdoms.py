#!/usr/bin/env python

from ansible.errors import AnsibleFilterError


class FilterModule(object):
    def filters(self):
        return {
            "get_firewall_vdoms": self.get_firewall_vdoms,
        }

    def get_firewall_vdoms(self, interfaces):
        vdoms = frozenset()

        for interface in interfaces:
            if not ("vdcs" in interface and interface["vdcs"] is not None):
                continue
            for vdc in interface["vdcs"]:
                vdoms = vdoms | frozenset([vdc["name"]])

        ret = []
        # make sure root vdom is first
        if "root" in vdoms:
            vdoms = vdoms - frozenset(["root"])
            ret.append("root")
        return ret + sorted(list(vdoms))
