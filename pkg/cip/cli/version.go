/*
Copyright 2020 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package cli

import (
	"fmt"

	"github.com/pkg/errors"

	"k8s.io/release/pkg/version"
)

type VersionOptions struct {
	JSON bool
}

func RunVersionCmd(opts *VersionOptions) error {
	v := version.Get()
	res := v.String()

	if opts.JSON {
		j, err := v.JSONString()
		if err != nil {
			return errors.Wrap(err, "unable to generate JSON from version info")
		}
		res = j
	}

	fmt.Println(res)
	return nil
}
