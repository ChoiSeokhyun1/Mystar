package controller.Admin;

import dao.admin.AdminDAO;
import dao.pve.BuildDAO;
import dto.pack.PackDTO;
import dto.player.PlayerDTO;
import dto.pve.BuildDTO;
import dto.pve.BuildUnitDTO;
import dto.pve.PveOpponentInfoDTO;
import dto.pve.PveSubstageDTO;
import dto.user.UserDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import org.springframework.web.multipart.MultipartFile;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.util.UUID;
import java.util.*;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AdminDAO adminDAO;

    @Autowired
    private BuildDAO buildDAO;

    private boolean isAdmin(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        return loginUser != null && "testuser3".equals(loginUser.getUserId());
    }

    /** JSON 문자열 이스케이프 */
    private String je(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", " ")
                .replace("\t", " ");
    }

    @GetMapping("/stage")
    public String adminStagePage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";

        List<Integer> stageLevels = adminDAO.findAllStageLevels();
        List<PlayerDTO> allPlayers = adminDAO.findAllPlayers();

        Map<Integer, List<PveSubstageDTO>> stageSubstageMap = new LinkedHashMap<>();
        for (int level : stageLevels) {
            stageSubstageMap.put(level, adminDAO.findSubstagesByStageLevel(level));
        }

        // 선수 JSON
        StringBuilder playerJson = new StringBuilder("[");
        for (int i = 0; i < allPlayers.size(); i++) {
            PlayerDTO p = allPlayers.get(i);
            if (i > 0) playerJson.append(",");
            playerJson.append("{")
                .append("\"seq\":").append(p.getPlayerSeq()).append(",")
                .append("\"name\":\"").append(je(p.getPlayerName())).append("\",")
                .append("\"race\":\"").append(je(p.getRace())).append("\",")
                .append("\"rarity\":\"").append(je(p.getRarity())).append("\",")
                .append("\"atk\":").append(p.getStatAttack()).append(",")
                .append("\"def\":").append(p.getStatDefense()).append(",")
                .append("\"mac\":").append(p.getStatMacro()).append(",")
                .append("\"mic\":").append(p.getStatMicro()).append(",")
                .append("\"lck\":").append(p.getStatLuck())
                .append("}");
        }
        playerJson.append("]");

        // 라운드 JSON
        StringBuilder roundJson = new StringBuilder("{");
        boolean firstLevel = true;
        for (Map.Entry<Integer, List<PveSubstageDTO>> entry : stageSubstageMap.entrySet()) {
            if (!firstLevel) roundJson.append(",");
            firstLevel = false;
            roundJson.append("\"").append(entry.getKey()).append("\":{");
            boolean firstSub = true;
            for (PveSubstageDTO sub : entry.getValue()) {
                if (!firstSub) roundJson.append(",");
                firstSub = false;
                roundJson.append("\"").append(sub.getSubLevel()).append("\":{")
                    .append("\"title\":\"").append(je(sub.getSubTitle())).append("\",")
                    .append("\"team\":\"").append(je(sub.getOpponentTeamName())).append("\"")
                    .append("}");
            }
            roundJson.append("}");
        }
        roundJson.append("}");

        // 팩 JSON - 팩 목록 + 각 팩에 속한 playerSeq Set
        List<PackDTO> allPacks = adminDAO.findAllPacks();
        StringBuilder packJson = new StringBuilder("[");
        for (int i = 0; i < allPacks.size(); i++) {
            PackDTO pk = allPacks.get(i);
            if (i > 0) packJson.append(",");
            List<Integer> seqs = adminDAO.findPlayerSeqsByPack(pk.getPackSeq());
            packJson.append("{")
                .append("\"seq\":").append(pk.getPackSeq()).append(",")
                .append("\"name\":\"").append(je(pk.getPackName())).append("\",")
                .append("\"players\":[");
            for (int j = 0; j < seqs.size(); j++) {
                if (j > 0) packJson.append(",");
                packJson.append(seqs.get(j));
            }
            packJson.append("]}");
        }
        packJson.append("]");

        // 빌드 JSON
        List<Map<String, Object>> allBuilds = adminDAO.findAllBuilds();
        StringBuilder buildJson = new StringBuilder("[");
        for (int i = 0; i < allBuilds.size(); i++) {
            Map<String, Object> b = allBuilds.get(i);
            if (i > 0) buildJson.append(",");
            buildJson.append("{")
                .append("\"id\":").append(b.get("BUILDID") != null ? b.get("BUILDID") : b.get("buildId")).append(",")
                .append("\"name\":\"").append(je(String.valueOf(b.get("BUILDNAME") != null ? b.get("BUILDNAME") : b.get("buildName")))).append("\",")
                .append("\"race\":\"").append(je(String.valueOf(b.get("RACE") != null ? b.get("RACE") : b.get("race")))).append("\",")
                .append("\"vsRace\":\"").append(je(String.valueOf(b.get("VSRACE") != null ? b.get("VSRACE") : b.get("vsRace")))).append("\",")
                .append("\"playStyle\":\"").append(je(String.valueOf(b.get("PLAYSTYLE") != null ? b.get("PLAYSTYLE") : b.get("playStyle")))).append("\",")
                .append("\"harassStyle\":\"").append(je(String.valueOf(b.get("HARASSSTYLE") != null ? b.get("HARASSSTYLE") : b.getOrDefault("harassStyle", "NORMAL_HARASS")))).append("\",")
                .append("\"aggression\":\"").append(je(String.valueOf(b.get("AGGRESSION") != null ? b.get("AGGRESSION") : b.get("aggression")))).append("\",")
                .append("\"userId\":\"").append(je(String.valueOf(b.get("USERID") != null ? b.get("USERID") : b.get("userId")))).append("\"")
                .append("}");
        }
        buildJson.append("]");

        // 맵 JSON
        List<Map<String, Object>> allMaps = adminDAO.findAllMaps();
        StringBuilder mapJson = new StringBuilder("[");
        for (int i = 0; i < allMaps.size(); i++) {
            Map<String, Object> m = allMaps.get(i);
            if (i > 0) mapJson.append(",");
            mapJson.append("{")
                .append("\"id\":\"").append(je(String.valueOf(m.getOrDefault("MAPID", m.get("mapId"))))).append("\",")
                .append("\"name\":\"").append(je(String.valueOf(m.getOrDefault("MAPNAME", m.get("mapName"))))).append("\"")
                .append("}");
        }
        mapJson.append("]");

        model.addAttribute("stageLevels", stageLevels);
        model.addAttribute("stageSubstageMap", stageSubstageMap);
        model.addAttribute("playerJsonData", playerJson.toString());
        model.addAttribute("roundJsonData", roundJson.toString());
        model.addAttribute("packJsonData", packJson.toString());
        model.addAttribute("buildJsonData", buildJson.toString());
        model.addAttribute("mapJsonData", mapJson.toString());
        return "adminStage";
    }

    @PostMapping("/stage/add")
    @ResponseBody
    public Map<String, Object> addStage(HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int newLevel = adminDAO.findMaxStageLevel() + 1;
            PveSubstageDTO dto = new PveSubstageDTO();
            dto.setStageLevel(newLevel);
            dto.setSubLevel(1);
            dto.setSubTitle("스테이지 " + newLevel + " - 라운드 1");
            dto.setOpponentTeamName("AI Team");
            adminDAO.insertSubstage(dto);
            res.put("success", true);
            res.put("newLevel", newLevel);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "추가 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/stage/delete")
    @ResponseBody
    public Map<String, Object> deleteStage(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int level = body.get("stageLevel");
            adminDAO.deleteOpponentsByStage(level);         // FK: opponents 먼저
            adminDAO.deleteStage(level);                    // 그 다음 substages
            adminDAO.deleteProgressByStage(level);          // 유저 스테이지 진행기록
            adminDAO.deleteSubstageProgressByStage(level);  // 유저 서브스테이지 진행기록
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/add")
    @ResponseBody
    public Map<String, Object> addRound(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int stageLevel = (int) body.get("stageLevel");
            String subTitle = (String) body.getOrDefault("subTitle", "새 라운드");
            String teamName = (String) body.getOrDefault("opponentTeamName", "AI Team");
            int newSubLevel = adminDAO.findMaxSubLevel(stageLevel) + 1;
            PveSubstageDTO dto = new PveSubstageDTO();
            dto.setStageLevel(stageLevel);
            dto.setSubLevel(newSubLevel);
            dto.setSubTitle(subTitle);
            dto.setOpponentTeamName(teamName);
            adminDAO.insertSubstage(dto);
            res.put("success", true);
            res.put("newSubLevel", newSubLevel);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "추가 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/edit")
    @ResponseBody
    public Map<String, Object> editRound(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            PveSubstageDTO dto = new PveSubstageDTO();
            dto.setStageLevel((int) body.get("stageLevel"));
            dto.setSubLevel((int) body.get("subLevel"));
            dto.setSubTitle((String) body.get("subTitle"));
            dto.setOpponentTeamName((String) body.get("opponentTeamName"));
            int rows = adminDAO.updateSubstage(dto);
            res.put("success", rows > 0);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "수정 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/delete")
    @ResponseBody
    public Map<String, Object> deleteRound(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", body.get("stageLevel"));
            params.put("subLevel", body.get("subLevel"));
            adminDAO.deleteOpponentsBySubstage(params);          // FK: opponents 먼저
            adminDAO.deleteSubstage(params);                     // 그 다음 substage
            adminDAO.deleteSubstageProgressBySubstage(params);   // 유저 서브스테이지 진행기록
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    @GetMapping("/round/opponents")
    @ResponseBody
    public Map<String, Object> getOpponents(
            @RequestParam int stageLevel, @RequestParam int subLevel, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", stageLevel);
            params.put("subLevel", subLevel);
            res.put("success", true);
            res.put("opponents", adminDAO.findOpponentsBySubstage(params));
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/opponent/assign")
    @ResponseBody
    public Map<String, Object> assignOpponent(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int stageLevel = (int) body.get("stageLevel");
            int subLevel   = (int) body.get("subLevel");
            int setNumber  = (int) body.get("setNumber");
            int playerSeq  = (int) body.get("playerSeq");
            Map<String, Object> del = new HashMap<>();
            del.put("stageLevel", stageLevel); del.put("subLevel", subLevel); del.put("setNumber", setNumber);
            adminDAO.deleteOpponentBySet(del);
            Map<String, Object> ins = new HashMap<>();
            ins.put("stageLevel", stageLevel); ins.put("subLevel", subLevel);
            ins.put("setNumber", setNumber);   ins.put("playerSeq", playerSeq);
            Object buildIdObj = body.get("buildId");
            if (buildIdObj != null) {
                ins.put("buildId", (int) buildIdObj);
            }
            adminDAO.insertOpponent(ins);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "배정 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/opponent/remove")
    @ResponseBody
    public Map<String, Object> removeOpponent(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", body.get("stageLevel"));
            params.put("subLevel", body.get("subLevel"));
            params.put("setNumber", body.get("setNumber"));
            adminDAO.deleteOpponentBySet(params);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "제거 실패: " + e.getMessage());
        }
        return res;
    }

    // ========================================================
    // 세트별 맵 관리
    // ========================================================

    @GetMapping("/round/maps")
    @ResponseBody
    public Map<String, Object> getSubstageMaps(
            @RequestParam int stageLevel, @RequestParam int subLevel, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", stageLevel);
            params.put("subLevel", subLevel);
            res.put("success", true);
            res.put("maps", adminDAO.findSubstageMaps(params));
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/map/assign")
    @ResponseBody
    public Map<String, Object> assignMap(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", (int) body.get("stageLevel"));
            params.put("subLevel",   (int) body.get("subLevel"));
            params.put("setNumber",  (int) body.get("setNumber"));
            params.put("mapId",      (String) body.get("mapId"));
            adminDAO.deleteSubstageMapBySet(params); // UPSERT: 기존 삭제 후 재삽입
            adminDAO.insertSubstageMap(params);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "맵 배정 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/round/map/remove")
    @ResponseBody
    public Map<String, Object> removeMap(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", toInt(body.get("stageLevel")));
            params.put("subLevel",   toInt(body.get("subLevel")));
            params.put("setNumber",  toInt(body.get("setNumber")));
            adminDAO.deleteSubstageMapBySet(params);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "맵 제거 실패: " + e.getMessage());
        }
        return res;
    }

    @GetMapping("/players")
    @ResponseBody
    public Map<String, Object> getAllPlayers(HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        try {
            res.put("success", true);
            res.put("players", adminDAO.findAllPlayers());
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
        }
        return res;
    }

    // ========================================================
    // 선수 관리 페이지
    // ========================================================
    @GetMapping("/player")
    public String adminPlayerPage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";
        List<PlayerDTO> players = adminDAO.findAllPlayersForAdmin();
        List<PackDTO> allPacks  = adminDAO.findAllPacks();

        // 선수 JSON (소속 팩 목록 포함)
        StringBuilder playerJson = new StringBuilder("[");
        for (int i = 0; i < players.size(); i++) {
            PlayerDTO p = players.get(i);
            if (i > 0) playerJson.append(",");
            List<Map<String, Object>> packsWithProb = adminDAO.findPacksWithProbByPlayerSeq(p.getPlayerSeq());
            playerJson.append("{")
                .append("\"seq\":").append(p.getPlayerSeq()).append(",")
                .append("\"name\":\"").append(je(p.getPlayerName())).append("\",")
                .append("\"race\":\"").append(je(p.getRace())).append("\",")
                .append("\"rarity\":\"").append(je(p.getRarity())).append("\",")
                .append("\"atk\":").append(p.getStatAttack()).append(",")
                .append("\"def\":").append(p.getStatDefense()).append(",")
                .append("\"mac\":").append(p.getStatMacro()).append(",")
                .append("\"mic\":").append(p.getStatMicro()).append(",")
                .append("\"lck\":").append(p.getStatLuck()).append(",")
                .append("\"imgUrl\":\"").append(je(p.getPlayerImgUrl() != null ? p.getPlayerImgUrl() : "")).append("\",")
                .append("\"cost\":").append(p.getPlayerCost()).append(",")
                .append("\"packs\":[");
            for (int j = 0; j < packsWithProb.size(); j++) {
                if (j > 0) playerJson.append(",");
                Map<String, Object> pw = packsWithProb.get(j);
                Object probObj = pw.get("DRAWPROBABILITY") != null ? pw.get("DRAWPROBABILITY") : pw.get("drawProbability");
                double prob = probObj instanceof Number ? ((Number) probObj).doubleValue() : 0.1;
                playerJson.append("{")
                    .append("\"seq\":").append(pw.get("PACKSEQ") != null ? pw.get("PACKSEQ") : pw.get("packSeq")).append(",")
                    .append("\"name\":\"").append(je(String.valueOf(pw.get("PACKNAME") != null ? pw.get("PACKNAME") : pw.get("packName")))).append("\",")
                    .append("\"prob\":").append(prob)
                    .append("}");
            }
            playerJson.append("]}");
        }
        playerJson.append("]");

        // 팩 목록 JSON
        StringBuilder packJson = new StringBuilder("[");
        for (int i = 0; i < allPacks.size(); i++) {
            if (i > 0) packJson.append(",");
            packJson.append("{")
                .append("\"seq\":").append(allPacks.get(i).getPackSeq()).append(",")
                .append("\"name\":\"").append(je(allPacks.get(i).getPackName())).append("\"")
                .append("}");
        }
        packJson.append("]");

        model.addAttribute("playerJsonData", playerJson.toString());
        model.addAttribute("packJsonData", packJson.toString());
        return "adminPlayer";
    }

    @PostMapping("/player/add")
    @ResponseBody
    public Map<String, Object> addPlayer(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            PlayerDTO dto = new PlayerDTO();
            dto.setPlayerName((String) body.get("playerName"));
            dto.setRace((String) body.get("race"));
            dto.setRarity((String) body.get("rarity"));
            dto.setStatAttack(toInt(body.get("statAttack")));
            dto.setStatDefense(toInt(body.get("statDefense")));
            dto.setStatMacro(toInt(body.get("statMacro")));
            dto.setStatMicro(toInt(body.get("statMicro")));
            dto.setStatLuck(toInt(body.get("statLuck")));
            dto.setPlayerImgUrl((String) body.getOrDefault("playerImgUrl", ""));
            dto.setPlayerCost(toInt(body.get("playerCost")));
            adminDAO.insertPlayer(dto);

            // 새로 생성된 seq 조회
            List<PlayerDTO> all = adminDAO.findAllPlayersForAdmin();
            int newSeq = 0;
            for (PlayerDTO p : all) {
                if (p.getPlayerName().equals(dto.getPlayerName())) newSeq = Math.max(newSeq, p.getPlayerSeq());
            }

            // 팩 연결 (확률 포함)
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> packInfos = (List<Map<String, Object>>) body.get("packInfos");
            if (packInfos != null && newSeq > 0) {
                for (Map<String, Object> info : packInfos) {
                    Map<String, Object> pm = new HashMap<>();
                    pm.put("packSeq", toInt(info.get("seq")));
                    pm.put("playerSeq", newSeq);
                    double prob = info.get("prob") instanceof Number ? ((Number) info.get("prob")).doubleValue() : 0.1;
                    if (prob <= 0 || prob > 1) prob = 0.1;
                    pm.put("drawProbability", prob);
                    adminDAO.insertPackContent(pm);
                }
            }
            res.put("success", true);
            res.put("newSeq", newSeq);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "추가 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/player/edit")
    @ResponseBody
    public Map<String, Object> editPlayer(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            PlayerDTO dto = new PlayerDTO();
            int playerSeq = toInt(body.get("playerSeq"));
            dto.setPlayerSeq(playerSeq);
            dto.setPlayerName((String) body.get("playerName"));
            dto.setRace((String) body.get("race"));
            dto.setRarity((String) body.get("rarity"));
            dto.setStatAttack(toInt(body.get("statAttack")));
            dto.setStatDefense(toInt(body.get("statDefense")));
            dto.setStatMacro(toInt(body.get("statMacro")));
            dto.setStatMicro(toInt(body.get("statMicro")));
            dto.setStatLuck(toInt(body.get("statLuck")));
            dto.setPlayerImgUrl((String) body.getOrDefault("playerImgUrl", ""));
            dto.setPlayerCost(toInt(body.get("playerCost")));
            adminDAO.updatePlayer(dto);

            // 팩 연결 전체 교체 (기존 삭제 후 재삽입)
            adminDAO.deleteAllPackContentsByPlayer(playerSeq);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> packInfos = (List<Map<String, Object>>) body.get("packInfos");
            if (packInfos != null) {
                for (Map<String, Object> info : packInfos) {
                    Map<String, Object> pm = new HashMap<>();
                    pm.put("packSeq", toInt(info.get("seq")));
                    pm.put("playerSeq", playerSeq);
                    double prob = info.get("prob") instanceof Number ? ((Number) info.get("prob")).doubleValue() : 0.1;
                    if (prob <= 0 || prob > 1) prob = 0.1;
                    pm.put("drawProbability", prob);
                    adminDAO.insertPackContent(pm);
                }
            }
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "수정 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/player/delete")
    @ResponseBody
    public Map<String, Object> deletePlayer(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int seq = body.get("playerSeq");
            // FK 순서대로 자식 테이블 먼저 삭제
            adminDAO.deleteMatchRecordsByPlayer(seq);   // 1. 경기 기록
            adminDAO.deletePveEntriesByPlayer(seq);     // 2. PVE 엔트리
            adminDAO.deleteOwnedPlayersByPlayer(seq);   // 3. 보유 선수
            adminDAO.deleteAllPackContentsByPlayer(seq); // 4. 팩 연결
            adminDAO.deletePveOpponentsByPlayer(seq);   // 5. PVE 상대
            adminDAO.deletePlayer(seq);                 // 6. 선수 본체
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    // ========================================================
    // 팩 관리 페이지
    // ========================================================

    /** 팩 관리 페이지 */
    @GetMapping("/pack")
    public String adminPackPage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";

        List<PackDTO> packs = adminDAO.findAllPacksForAdmin();
        List<PlayerDTO> players = adminDAO.findAllPlayersForAdmin();

        // 팩 JSON (전체 필드)
        StringBuilder packJson = new StringBuilder("[");
        for (int i = 0; i < packs.size(); i++) {
            PackDTO pk = packs.get(i);
            if (i > 0) packJson.append(",");
            packJson.append("{")
                .append("\"packSeq\":").append(pk.getPackSeq()).append(",")
                .append("\"packName\":\"").append(je(pk.getPackName())).append("\",")
                .append("\"description\":\"").append(je(pk.getDescription() != null ? pk.getDescription() : "")).append("\",")
                .append("\"costCrystal\":").append(pk.getCostCrystal()).append(",")
                .append("\"bannerImgUrl\":\"").append(je(pk.getBannerImgUrl() != null ? pk.getBannerImgUrl() : "")).append("\",")
                .append("\"isAvailable\":\"").append(je(pk.getIsAvailable() != null ? pk.getIsAvailable() : "Y")).append("\"")
                .append("}");
        }
        packJson.append("]");

        // 선수 JSON (소속 팩 포함) — adminPlayer 방식 재활용
        StringBuilder playerJson = new StringBuilder("[");
        for (int i = 0; i < players.size(); i++) {
            PlayerDTO p = players.get(i);
            if (i > 0) playerJson.append(",");
            List<PackDTO> playerPacks = adminDAO.findPacksByPlayerSeq(p.getPlayerSeq());
            playerJson.append("{")
                .append("\"seq\":").append(p.getPlayerSeq()).append(",")
                .append("\"name\":\"").append(je(p.getPlayerName())).append("\",")
                .append("\"race\":\"").append(je(p.getRace())).append("\",")
                .append("\"rarity\":\"").append(je(p.getRarity())).append("\",")
                .append("\"imgUrl\":\"").append(je(p.getPlayerImgUrl() != null ? p.getPlayerImgUrl() : "")).append("\",")
                .append("\"packs\":[");
            for (int j = 0; j < playerPacks.size(); j++) {
                if (j > 0) playerJson.append(",");
                playerJson.append("{")
                    .append("\"seq\":").append(playerPacks.get(j).getPackSeq()).append(",")
                    .append("\"name\":\"").append(je(playerPacks.get(j).getPackName())).append("\"")
                    .append("}");
            }
            playerJson.append("]}");
        }
        playerJson.append("]");

        model.addAttribute("packJsonData", packJson.toString());
        model.addAttribute("allPlayersJson", playerJson.toString());
        return "adminPack";
    }

    /** 팩 추가 */
    @PostMapping("/pack/add")
    @ResponseBody
    public Map<String, Object> addPack(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            PackDTO dto = buildPackDTO(body);
            adminDAO.insertPack(dto);
            // 새 seq 조회
            List<PackDTO> all = adminDAO.findAllPacksForAdmin();
            int newSeq = 0;
            for (PackDTO pk : all) {
                if (pk.getPackName().equals(dto.getPackName())) newSeq = Math.max(newSeq, pk.getPackSeq());
            }
            res.put("success", true);
            res.put("newSeq", newSeq);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "추가 실패: " + e.getMessage());
        }
        return res;
    }

    /** 팩 수정 */
    @PostMapping("/pack/edit")
    @ResponseBody
    public Map<String, Object> editPack(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            PackDTO dto = buildPackDTO(body);
            dto.setPackSeq(toInt(body.get("packSeq")));
            int rows = adminDAO.updatePack(dto);
            res.put("success", rows > 0);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "수정 실패: " + e.getMessage());
        }
        return res;
    }

    /** 팩 판매 ON/OFF 토글 */
    @PostMapping("/pack/toggle")
    @ResponseBody
    public Map<String, Object> togglePack(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("packSeq", toInt(body.get("packSeq")));
            params.put("isAvailable", body.get("isAvailable"));
            int rows = adminDAO.togglePackAvailable(params);
            res.put("success", rows > 0);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "변경 실패: " + e.getMessage());
        }
        return res;
    }

    /** 팩 삭제 */
    @PostMapping("/pack/delete")
    @ResponseBody
    public Map<String, Object> deletePack(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int packSeq = body.get("packSeq");
            adminDAO.deleteAllPackContentsByPack(packSeq);  // FK 먼저
            adminDAO.deletePack(packSeq);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    /** 팩 배너 이미지 업로드 */
    @PostMapping("/pack/upload")
    @ResponseBody
    public Map<String, Object> uploadPackImage(
            @RequestParam("file") MultipartFile file,
            HttpServletRequest request,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            String originalName = file.getOriginalFilename();
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf("."));
            }
            String saveName = UUID.randomUUID().toString() + ext;

            // 저장 경로: /resources/image/packs/
            String uploadDir = request.getServletContext().getRealPath("/resources/image/packs");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            file.transferTo(new File(dir, saveName));

            // 접근 URL (컨텍스트 경로 포함)
            String contextPath = request.getContextPath();
            String url = contextPath + "/image/packs/" + saveName;

            res.put("success", true);
            res.put("url", url);
        } catch (IOException e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "업로드 실패: " + e.getMessage());
        }
        return res;
    }

    /* ============================================================
       빌드 CRUD (관리자용)
       ============================================================ */

    /** 전체 빌드 목록 JSON (adminStage 페이지 갱신용) */
    @GetMapping("/builds/json")
    @ResponseBody
    public Map<String, Object> getAllBuildsJson(HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        List<Map<String, Object>> raw = adminDAO.findAllBuilds();
        List<Map<String, Object>> builds = new ArrayList<>();
        for (Map<String, Object> b : raw) {
            Map<String, Object> item = new HashMap<>();
            item.put("id",          toInt(b.getOrDefault("BUILDID", b.get("buildId"))));
            item.put("name",        b.getOrDefault("BUILDNAME", b.get("buildName")));
            item.put("race",        b.getOrDefault("RACE",      b.get("race")));
            item.put("vsRace",      b.getOrDefault("VSRACE",    b.get("vsRace")));
            item.put("playStyle",    b.getOrDefault("PLAYSTYLE",   b.get("playStyle")));
            item.put("harassStyle",  b.getOrDefault("HARASSSTYLE", b.getOrDefault("harassStyle", "NORMAL_HARASS")));
            item.put("aggression",   b.getOrDefault("AGGRESSION",  b.get("aggression")));
            builds.add(item);
        }
        res.put("success", true);
        res.put("builds", builds);
        return res;
    }

    /** 단건 빌드 + 유닛 조회 */
    @GetMapping("/builds/{buildId}")
    @ResponseBody
    public Map<String, Object> getBuild(@PathVariable int buildId, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        BuildDTO build = buildDAO.selectBuildById(buildId);
        if (build == null) { res.put("success", false); res.put("message", "빌드 없음"); return res; }
        res.put("success", true);
        res.put("build", build);
        return res;
    }

    /** 빌드 생성 */
    @PostMapping("/builds/create")
    @ResponseBody
    public Map<String, Object> createBuild(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            BuildDTO build = new BuildDTO();
            build.setBuildName((String) body.get("buildName"));
            build.setRace((String) body.get("race"));
            build.setVsRace((String) body.getOrDefault("vsRace", "A"));
            build.setPlayStyle((String) body.getOrDefault("playStyle", "AGGRESSIVE"));
            build.setHarassStyle((String) body.getOrDefault("harassStyle", "NORMAL_HARASS"));
            build.setAggression((String) body.getOrDefault("aggression", "MID_MULTI"));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> units = (List<Map<String, Object>>) body.get("units");
            if (units != null) {
                for (Map<String, Object> u : units) {
                    BuildUnitDTO unit = new BuildUnitDTO();
                    unit.setBuildId(build.getBuildId());
                    unit.setPhase((String) u.get("phase"));
                    unit.setUnitId((String) u.get("unitId"));
                    unit.setPriority(toInt(u.get("priority")));
                    buildDAO.insertBuildUnit(unit);
                }
            }
            res.put("success", true);
            res.put("buildId", build.getBuildId());
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "생성 실패: " + e.getMessage());
        }
        return res;
    }

    /** 빌드 수정 */
    @PostMapping("/builds/update")
    @ResponseBody
    public Map<String, Object> updateBuild(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int buildId = toInt(body.get("buildId"));
            BuildDTO build = new BuildDTO();
            build.setBuildId(buildId);
            build.setBuildName((String) body.get("buildName"));
            build.setRace((String) body.get("race"));
            build.setVsRace((String) body.getOrDefault("vsRace", "A"));
            build.setPlayStyle((String) body.getOrDefault("playStyle", "AGGRESSIVE"));
            build.setHarassStyle((String) body.getOrDefault("harassStyle", "NORMAL_HARASS"));
            build.setAggression((String) body.getOrDefault("aggression", "MID_MULTI"));
            build.setPreferredUnits((String) body.getOrDefault("preferredUnits", ""));
            build.setPreferredBuildings((String) body.getOrDefault("preferredBuildings", ""));
            buildDAO.updateBuild(build);

            buildDAO.deleteBuildUnitsByBuildId(buildId);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> units = (List<Map<String, Object>>) body.get("units");
            if (units != null) {
                for (Map<String, Object> u : units) {
                    BuildUnitDTO unit = new BuildUnitDTO();
                    unit.setBuildId(buildId);
                    unit.setPhase((String) u.get("phase"));
                    unit.setUnitId((String) u.get("unitId"));
                    unit.setPriority(toInt(u.get("priority")));
                    buildDAO.insertBuildUnit(unit);
                }
            }
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "수정 실패: " + e.getMessage());
        }
        return res;
    }

    /** 빌드 삭제 */
    @PostMapping("/builds/delete")
    @ResponseBody
    public Map<String, Object> deleteBuild(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int buildId = toInt(body.get("buildId"));
            buildDAO.nullifyOpponentBuildId(buildId);   // 1. PVE 상대 BUILD_ID → NULL
            buildDAO.deleteOwnedBuildsByBuildId(buildId); // 2. 선수-빌드 연결 삭제
            buildDAO.deleteBuildUnitsByBuildId(buildId);  // 3. 유닛 설정 삭제
            buildDAO.deleteBuild(buildId);                // 4. 빌드 본체 삭제
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    /** PackDTO 빌더 헬퍼 */
    private PackDTO buildPackDTO(Map<String, Object> body) {
        PackDTO dto = new PackDTO();
        dto.setPackName((String) body.get("packName"));
        dto.setDescription((String) body.getOrDefault("description", ""));
        dto.setCostCrystal(toInt(body.get("costCrystal")));
        dto.setBannerImgUrl((String) body.getOrDefault("bannerImgUrl", ""));
        dto.setIsAvailable((String) body.getOrDefault("isAvailable", "Y"));
        return dto;
    }

    private int toInt(Object val) {
        if (val == null) return 0;
        if (val instanceof Integer) return (Integer) val;
        try { return Integer.parseInt(val.toString()); } catch (Exception e) { return 0; }
    }

    /* ============================================================
       유닛/건물 이미지 관리
       ============================================================ */

    @GetMapping("/entity")
    public String adminEntityPage(HttpSession session, Model model, HttpServletRequest request) {
        if (!isAdmin(session)) return "redirect:/login";

        String entityDir = request.getServletContext().getRealPath("/resources/image/entities");
        File dir = new File(entityDir);
        Map<String, String> existingImages = new HashMap<>();
        if (dir.exists() && dir.listFiles() != null) {
            for (File f : dir.listFiles()) {
                String fname = f.getName();
                int dot = fname.lastIndexOf('.');
                String key = dot > 0 ? fname.substring(0, dot) : fname;
                existingImages.put(key, request.getContextPath() + "/image/entities/" + fname);
            }
        }

        String[][] defs = {
            {"command_center","커맨드센터","building","T"},{"refinery","정제소","building","T"},
            {"barracks","배럭스","building","T"},{"academy","아카데미","building","T"},
            {"factory","팩토리","building","T"},{"machine_shop","머신샵","building","T"},
            {"armory","아머리","building","T"},{"starport","스타포트","building","T"},
            {"science_facility","사이언스 퍼실리티","building","T"},
            {"nuclear_silo","뉴클리어 어댑터","building","T"},
            {"battle_adaptor","배틀 어댑터","building","T"},
            {"scv","SCV","unit","T"},{"marine","마린","unit","T"},
            {"firebat","파이어뱃","unit","T"},{"medic","메딕","unit","T"},
            {"vulture","벌처","unit","T"},{"tank","탱크","unit","T"},
            {"goliath","골리앗","unit","T"},{"wraith","레이스","unit","T"},
            {"dropship","드랍쉽","unit","T"},{"vessel","사이언스베슬","unit","T"},
            {"ghost","고스트","unit","T"},{"battlecruiser","배틀크루저","unit","T"},
            {"hatchery","해처리","building","Z"},{"extractor","추출기","building","Z"},
            {"spawning_pool","스포닝풀","building","Z"},{"hydralisk_den","히드라덴","building","Z"},
            {"spire","스파이어","building","Z"},{"lurker_aspect","러커어스펙트","building","Z"},
            {"drone","드론","unit","Z"},{"zergling","저글링","unit","Z"},
            {"hydralisk","히드라리스크","unit","Z"},{"mutalisk","뮤탈리스크","unit","Z"},
            {"lurker","러커","unit","Z"},
            {"nexus","넥서스","building","P"},{"assimilator","동화기","building","P"},
            {"gateway","게이트웨이","building","P"},{"cybernetics_core","사이버네틱스코어","building","P"},
            {"citadel","시타델","building","P"},{"robotics","로보틱스","building","P"},
            {"probe","프로브","unit","P"},{"zealot","질럿","unit","P"},
            {"dragoon","드라군","unit","P"},{"dark_templar","다크템플러","unit","P"},
            {"reaver","리버","unit","P"},{"high_templar","하이템플러","unit","P"},
            {"corsair","커세어","unit","P"},{"carrier","캐리어","unit","P"}
        };

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < defs.length; i++) {
            String[] d = defs[i];
            String imgUrl = existingImages.get(d[0]);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"id\":\"").append(je(d[0])).append("\",")
                .append("\"displayName\":\"").append(je(d[1])).append("\",")
                .append("\"type\":\"").append(je(d[2])).append("\",")
                .append("\"race\":\"").append(je(d[3])).append("\",")
                .append("\"imageUrl\":").append(imgUrl != null ? "\"" + je(imgUrl) + "\"" : "null")
                .append("}");
        }
        json.append("]");
        model.addAttribute("entitiesJson", json.toString());
        return "adminEntity";
    }

    @PostMapping("/entity/upload")
    @ResponseBody
    public Map<String, Object> uploadEntityImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("entityId") String entityId,
            HttpServletRequest request,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            String originalName = file.getOriginalFilename();
            String ext = ".png";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
            }
            String saveName = entityId + ext;
            String uploadDir = request.getServletContext().getRealPath("/resources/image/entities");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            if (dir.listFiles() != null) {
                for (File f : dir.listFiles()) {
                    String fn = f.getName();
                    String key = fn.contains(".") ? fn.substring(0, fn.lastIndexOf('.')) : fn;
                    if (key.equals(entityId)) f.delete();
                }
            }
            file.transferTo(new File(dir, saveName));
            String url = request.getContextPath() + "/image/entities/" + saveName;
            res.put("success", true);
            res.put("url", url);
        } catch (IOException e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "업로드 실패: " + e.getMessage());
        }
        return res;
    }

    @PostMapping("/entity/delete")
    @ResponseBody
    public Map<String, Object> deleteEntityImage(
            @RequestParam("entityId") String entityId,
            HttpServletRequest request,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        String uploadDir = request.getServletContext().getRealPath("/resources/image/entities");
        File dir = new File(uploadDir);
        if (dir.exists() && dir.listFiles() != null) {
            for (File f : dir.listFiles()) {
                String fn = f.getName();
                String key = fn.contains(".") ? fn.substring(0, fn.lastIndexOf('.')) : fn;
                if (key.equals(entityId)) { f.delete(); break; }
            }
        }
        res.put("success", true);
        return res;
    }

}