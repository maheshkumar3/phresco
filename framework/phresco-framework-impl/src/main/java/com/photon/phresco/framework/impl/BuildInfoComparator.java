/*
 * ###
 * Phresco Framework Implementation
 * 
 * Copyright (C) 1999 - 2012 Photon Infotech Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ###
 */
package com.photon.phresco.framework.impl;

import java.util.Comparator;

import com.photon.phresco.commons.BuildInfo;

public class BuildInfoComparator implements Comparator<BuildInfo> {

    @Override
    public int compare(BuildInfo info1, BuildInfo info2) {
    	Integer build1 = info1.getBuildNo();
    	Integer build2 = info2.getBuildNo();
        return (build1 > build2) ? -1 : (build1 == build2 ? 0 : 1);
    }
}
