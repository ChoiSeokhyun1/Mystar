package controller.Main;

import dao.admin.AdminDAO;
import dto.pve.MapPointDTO;
import dto.pve.PveStageMapDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/map")
public class MapApiController {

    @Autowired
    private AdminDAO adminDAO;

    @GetMapping("/info")
    public Map<String, Object> getMapInfo(
            @RequestParam(value = "mapId", required = false) String mapId,
            @RequestParam(value = "stageLevel", required = false, defaultValue = "0") int stageLevel,
            @RequestParam(value = "subLevel", required = false, defaultValue = "0") int subLevel,
            @RequestParam(value = "setNum", required = false, defaultValue = "0") int setNum,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();

        try {
            // 1. mapId가 누락되었거나 null 문자열인 경우 DB에서 직접 해당 세트의 맵을 찾습니다 (안전장치)
            if (mapId == null || mapId.trim().isEmpty() || mapId.equals("undefined") || mapId.equals("null")) {
                if (stageLevel > 0 && subLevel > 0 && setNum > 0) {
                    Map<String, Object> params = new HashMap<>();
                    params.put("stageLevel", stageLevel);
                    params.put("subLevel", subLevel);
                    List<PveStageMapDTO> maps = adminDAO.findSubstageMaps(params);
                    if (maps != null) {
                        for (PveStageMapDTO m : maps) {
                            if (m.getSetNumber() == setNum) {
                                mapId = m.getMapId();
                                break;
                            }
                        }
                    }
                }
            }

            // 그래도 mapId를 찾지 못했다면 에러 반환
            if (mapId == null || mapId.trim().isEmpty() || mapId.equals("undefined") || mapId.equals("null")) {
                response.put("success", false);
                response.put("error", "해당 세트에 배정된 맵이 없습니다.");
                return response;
            }

            // 2. 전체 맵 데이터에서 해당 mapId의 배경 이미지 URL 가져오기
            List<Map<String, Object>> allMaps = adminDAO.findAllMapsDetail();
            Map<String, Object> targetMap = null;
            
            for (Map<String, Object> map : allMaps) {
                // MyBatis 결과 맵핑 시 발생할 수 있는 대소문자/언더바 차이 모두 커버
                String id = (String) map.get("MAPID");
                if (id == null) id = (String) map.get("mapId");
                if (id == null) id = (String) map.get("MAP_ID");
                if (id == null) id = (String) map.get("map_id");

                if (mapId.equals(id)) {
                    targetMap = map;
                    break;
                }
            }

            if (targetMap != null) {
                String bgImageUrl = (String) targetMap.get("MAPIMGURL");
                if (bgImageUrl == null) bgImageUrl = (String) targetMap.get("mapImgUrl");
                if (bgImageUrl == null) bgImageUrl = (String) targetMap.get("map_img_url");
                
                response.put("bgImageUrl", bgImageUrl);
            }

            // 3. 지점(Point) 정보 가져오기 (A스타팅, B스타팅 등)
            List<MapPointDTO> points = adminDAO.findPointsByMapId(mapId);
            response.put("points", points != null ? points : new java.util.ArrayList<>());

         // 4. 종족별 건물 이미지 경로 전달
            String contextPath = request.getContextPath();
            response.put("terranCommandUrl", contextPath + "/image/entities/command_center.jpg");
            response.put("zergHatcheryUrl", contextPath + "/image/entities/hatchery.jpg");
            response.put("protossNexusUrl", contextPath + "/image/entities/nexus.jpg");
            
            response.put("success", true);
            response.put("mapId", mapId); // 최종 적용된 mapId 확인용

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "서버 에러: " + e.getMessage());
        }

        return response;
    }
}