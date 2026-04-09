package controller.Admin;

import dao.admin.AdminDAO;
import dao.pve.BuildDAO;
import dao.pve.ScriptDAO;
import dto.pack.PackDTO;
import dto.player.PlayerDTO;
import dto.pve.BuildDTO;
import dto.pve.PveOpponentInfoDTO;
import dto.pve.PveSubstageDTO;
import dto.pve.ScriptDTO;
import dto.user.UserDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import service.pve.BuildService;

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

    @Autowired
    private BuildService buildService;

    @Autowired
    private ScriptDAO scriptDAO;

    private boolean isAdmin(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        return loginUser != null && "testuser3".equals(loginUser.getUserId());
    }

    private String je(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", " ")
                .replace("\t", " ");
    }

    private int toInt(Object val) {
        if (val == null) return 0;
        if (val instanceof Integer) return (Integer) val;
        try { return Integer.parseInt(val.toString()); } catch (Exception e) { return 0; }
    }

    private PackDTO buildPackDTO(Map<String, Object> body) {
        PackDTO dto = new PackDTO();
        dto.setPackName((String) body.get("packName"));
        dto.setDescription((String) body.getOrDefault("description", ""));
        dto.setCostCrystal(toInt(body.get("costCrystal")));
        dto.setBannerImgUrl((String) body.getOrDefault("bannerImgUrl", ""));
        dto.setIsAvailable((String) body.getOrDefault("isAvailable", "Y"));
        return dto;
    }

    // ===================== STAGE =====================

    @GetMapping("/stage")
    public String adminStagePage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";

        List<Integer> stageLevels = adminDAO.findAllStageLevels();
        List<PlayerDTO> allPlayers = adminDAO.findAllPlayers();

        Map<Integer, List<PveSubstageDTO>> stageSubstageMap = new LinkedHashMap<>();
        for (int level : stageLevels) {
            stageSubstageMap.put(level, adminDAO.findSubstagesByStageLevel(level));
        }

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

        List<BuildDTO> allBuilds = buildService.getAllBuilds();
        StringBuilder buildJson = new StringBuilder("[");
        for (int i = 0; i < allBuilds.size(); i++) {
            BuildDTO b = allBuilds.get(i);
            if (i > 0) buildJson.append(",");
            buildJson.append("{")
                .append("\"id\":").append(b.getBuildId()).append(",")
                .append("\"name\":\"").append(je(b.getBuildName())).append("\",")
                .append("\"race\":\"").append(je(b.getRace())).append("\",")
                .append("\"vsRace\":\"").append(je(b.getVsRace() != null ? b.getVsRace() : "")).append("\"")
                .append("}");
        }
        buildJson.append("]");

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

    @Transactional
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

    @Transactional
    @PostMapping("/stage/delete")
    @ResponseBody
    public Map<String, Object> deleteStage(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int level = body.get("stageLevel");
            adminDAO.deleteOpponentsByStage(level);
            adminDAO.deleteSubstageMapsByStage(level);
            adminDAO.deleteStage(level);
            adminDAO.deleteProgressByStage(level);
            adminDAO.deleteSubstageProgressByStage(level);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    // ===================== ROUND =====================

    @Transactional
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

    @Transactional
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

    @Transactional
    @PostMapping("/round/delete")
    @ResponseBody
    public Map<String, Object> deleteRound(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("stageLevel", body.get("stageLevel"));
            params.put("subLevel", body.get("subLevel"));
            adminDAO.deleteOpponentsBySubstage(params);
            adminDAO.deleteSubstageMapsBySubstage(params);
            adminDAO.deleteSubstage(params);
            adminDAO.deleteSubstageProgressBySubstage(params);
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

    @Transactional
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
            Object buildIdVsTObj = body.get("buildIdVsT");
            Object buildIdVsZObj = body.get("buildIdVsZ");
            Object buildIdVsPObj = body.get("buildIdVsP");
            ins.put("buildIdVsT", buildIdVsTObj != null && !buildIdVsTObj.toString().isEmpty() ? toInt(buildIdVsTObj) : null);
            ins.put("buildIdVsZ", buildIdVsZObj != null && !buildIdVsZObj.toString().isEmpty() ? toInt(buildIdVsZObj) : null);
            ins.put("buildIdVsP", buildIdVsPObj != null && !buildIdVsPObj.toString().isEmpty() ? toInt(buildIdVsPObj) : null);
            adminDAO.insertOpponent(ins);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "배정 실패: " + e.getMessage());
        }
        return res;
    }

    @Transactional
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

    @Transactional
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
            adminDAO.deleteSubstageMapBySet(params);
            adminDAO.insertSubstageMap(params);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "맵 배정 실패: " + e.getMessage());
        }
        return res;
    }

    @Transactional
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

    // ===================== PLAYER =====================

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

    @GetMapping("/player")
    public String adminPlayerPage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";
        List<PlayerDTO> players = adminDAO.findAllPlayersForAdmin();
        List<PackDTO> allPacks  = adminDAO.findAllPacks();

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

    @Transactional
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
            int newSeq = adminDAO.findMaxPlayerSeq();
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

    @Transactional
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

    @Transactional
    @PostMapping("/player/delete")
    @ResponseBody
    public Map<String, Object> deletePlayer(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int seq = body.get("playerSeq");
            adminDAO.deleteMatchRecordsByPlayer(seq);
            adminDAO.deletePveEntriesByPlayer(seq);
            adminDAO.deleteOwnedPlayersByPlayer(seq);
            adminDAO.deleteAllPackContentsByPlayer(seq);
            adminDAO.deletePveOpponentsByPlayer(seq);
            adminDAO.deletePlayer(seq);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

    // ===================== PACK =====================

    @GetMapping("/pack")
    public String adminPackPage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";
        List<PackDTO> packs = adminDAO.findAllPacksForAdmin();
        List<PlayerDTO> players = adminDAO.findAllPlayersForAdmin();

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

    @Transactional
    @PostMapping("/pack/add")
    @ResponseBody
    public Map<String, Object> addPack(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            PackDTO dto = buildPackDTO(body);
            adminDAO.insertPack(dto);
            int newSeq = adminDAO.findMaxPackSeq();
            res.put("success", true);
            res.put("newSeq", newSeq);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "추가 실패: " + e.getMessage());
        }
        return res;
    }

    @Transactional
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

    @Transactional
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

    @Transactional
    @PostMapping("/pack/delete")
    @ResponseBody
    public Map<String, Object> deletePack(@RequestBody Map<String, Integer> body, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int packSeq = body.get("packSeq");
            adminDAO.deleteAllPackContentsByPack(packSeq);
            adminDAO.deletePack(packSeq);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "삭제 실패: " + e.getMessage());
        }
        return res;
    }

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
            String uploadDir = request.getServletContext().getRealPath("/resources/image/packs");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            file.transferTo(new File(dir, saveName));
            String url = request.getContextPath() + "/image/packs/" + saveName;
            res.put("success", true);
            res.put("url", url);
        } catch (IOException e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "업로드 실패: " + e.getMessage());
        }
        return res;
    }

    // ===================== BUILD =====================

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

    @GetMapping("/builds/{buildId}")
    @ResponseBody
    public Map<String, Object> getBuild(@PathVariable int buildId, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        BuildDTO build = buildService.getBuildById(buildId);  // statBonuses 포함 조회
        if (build == null) { res.put("success", false); res.put("message", "빌드 없음"); return res; }
        res.put("success", true);
        res.put("build", build);
        return res;
    }

    @GetMapping("/build/manage")
    public String adminBuildManage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/login";
        try {
            List<BuildDTO> allBuilds = buildService.getAllBuilds();
            if (allBuilds != null) {
                // 테이블 표시용으로 각 빌드의 statBonuses 로드
                for (BuildDTO b : allBuilds) {
                    b.setStatBonuses(scriptDAO.selectStatBonusesByBuildId(b.getBuildId()));
                }
            }
            model.addAttribute("builds", allBuilds != null ? allBuilds : new ArrayList<>());
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("builds", new ArrayList<>());
        }
        return "admin/buildManage";
    }

    @Transactional
    @PostMapping("/build/create")
    @ResponseBody
    public Map<String, Object> createAdminBuild(@RequestBody BuildDTO buildDto, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "관리자 권한이 필요합니다."); return res; }
        try {
            buildDto.setUserId("SYSTEM");   
            buildService.createBuild(buildDto);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "빌드 생성 실패: " + e.getMessage());
        }
        return res;
    }

    @Transactional
    @PostMapping("/build/edit")
    @ResponseBody
    public Map<String, Object> editAdminBuild(@RequestBody BuildDTO buildDto, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "관리자 권한이 필요합니다."); return res; }
        try {
            buildDto.setUserId("SYSTEM");   
            buildService.modifyBuild(buildDto);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "빌드 수정 실패: " + e.getMessage());
        }
        return res;
    }

    @Transactional
    @PostMapping("/build/update")
    @ResponseBody
    public Map<String, Object> updateAdminBuild(@RequestBody BuildDTO buildDto, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "관리자 권한이 필요합니다."); return res; }
        try {
            buildDto.setUserId("SYSTEM");
            buildService.modifyBuild(buildDto);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "빌드 수정 실패: " + e.getMessage());
        }
        return res;
    }

    @Transactional
    @PostMapping("/build/delete")
    @ResponseBody
    public Map<String, Object> deleteAdminBuild(@RequestParam("buildId") int buildId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        if (!isAdmin(session)) { response.put("success", false); response.put("message", "관리자 권한이 필요합니다."); return response; }
        try {
            buildService.removeBuild(buildId);
            response.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "빌드 삭제 실패: " + e.getMessage());
        }
        return response;
    }

    @GetMapping("/build/list-by-race")
    @ResponseBody
    public List<BuildDTO> getAdminBuildsByRace(
            @RequestParam("race") String race,
            @RequestParam(value = "vsRace", required = false) String vsRace,
            HttpSession session) {
        if (!isAdmin(session)) return new ArrayList<>();
        try {
            if (vsRace != null && !vsRace.isEmpty()) {
                return buildService.getBuildsByRaceAndVsRace(race, vsRace);
            }
            return buildService.getBuildsByRace(race);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // ===================== SCRIPT =====================

    @GetMapping("/script/manage")
    public String scriptManagePage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/login";
        List<BuildDTO> allBuilds = buildService.getAllBuilds();
        model.addAttribute("builds", allBuilds);
        StringBuilder buildJson = new StringBuilder("[");
        for (int i = 0; i < allBuilds.size(); i++) {
            BuildDTO b = allBuilds.get(i);
            if (i > 0) buildJson.append(",");
            buildJson.append("{")
                .append("\"buildId\":").append(b.getBuildId()).append(",")
                .append("\"buildName\":\"").append(je(b.getBuildName())).append("\",")
                .append("\"race\":\"").append(je(b.getRace())).append("\"")
                .append("}");
        }
        buildJson.append("]");
        model.addAttribute("buildJsonData", buildJson.toString());
        return "admin/scriptManage";
    }

    @GetMapping("/script/has-scripts")
    @ResponseBody
    public Map<String, Object> hasScripts(@RequestParam("buildAId") int buildAId, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        try {
            List<ScriptDTO> scripts = scriptDAO.selectScriptSummaryByMyBuild(buildAId);
            Map<Integer, Map<String, Boolean>> existsMap = new HashMap<>();
            if (scripts != null) {
                for (ScriptDTO s : scripts) {
                    int oppId = s.getOppBuildId();
                    existsMap.computeIfAbsent(oppId, k -> new HashMap<>());
                    if (s.getContent() != null && !s.getContent().trim().isEmpty()) {
                        existsMap.get(oppId).put(s.getResult(), true);
                    }
                }
            }
            List<ScriptDTO> reverseScripts = scriptDAO.selectScriptSummaryByOppBuild(buildAId);
            if (reverseScripts != null) {
                for (ScriptDTO s : reverseScripts) {
                    int myId = s.getMyBuildId();
                    existsMap.computeIfAbsent(myId, k -> new HashMap<>());
                    if (s.getContent() != null && !s.getContent().trim().isEmpty()) {
                        existsMap.get(myId).put(s.getResult(), true);
                    }
                }
            }
            Map<String, Object> result = new HashMap<>();
            for (Map.Entry<Integer, Map<String, Boolean>> entry : existsMap.entrySet()) {
                Map<String, Boolean> status = new HashMap<>();
                status.put("hasWin",  entry.getValue().getOrDefault("WIN",  false));
                status.put("hasLose", entry.getValue().getOrDefault("LOSE", false));
                result.put(String.valueOf(entry.getKey()), status);
            }
            res.put("success", true);
            res.put("scriptStatus", result);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("scriptStatus", new HashMap<>());
        }
        return res;
    }

    @PostMapping("/script/load")
    @ResponseBody
    public Map<String, Object> loadScripts(@RequestBody Map<String, Object> params, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        if (!isAdmin(session)) { result.put("success", false); result.put("message", "권한 없음"); return result; }
        try {
            int myBuildId  = Integer.parseInt(params.get("myBuildId").toString());
            int oppBuildId = Integer.parseInt(params.get("oppBuildId").toString());
            Map<String, Object> queryParams = new HashMap<>();
            queryParams.put("myBuildId", myBuildId);
            queryParams.put("oppBuildId", oppBuildId);
            List<ScriptDTO> scripts = scriptDAO.selectScriptsByMatchup(queryParams);
            result.put("success", true);
            result.put("scripts", scripts != null ? scripts : new ArrayList<>());
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "로드 실패: " + e.getMessage());
        }
        return result;
    }

    @Transactional
    @PostMapping("/script/save")
    @ResponseBody
    public Map<String, Object> saveScripts(@RequestBody Map<String, Object> params, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        if (!isAdmin(session)) { result.put("success", false); result.put("message", "권한 없음"); return result; }
        try {
            int myBuildId  = Integer.parseInt(params.get("myBuildId").toString());
            int oppBuildId = Integer.parseInt(params.get("oppBuildId").toString());
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> scriptList = (List<Map<String, Object>>) params.get("scripts");
            Map<String, Object> deleteParams = new HashMap<>();
            deleteParams.put("myBuildId", myBuildId);
            deleteParams.put("oppBuildId", oppBuildId);
            scriptDAO.deleteScriptsByBuildIds(deleteParams);
            if (scriptList != null && !scriptList.isEmpty()) {
                for (Map<String, Object> script : scriptList) {
                    ScriptDTO scriptDTO = new ScriptDTO();
                    scriptDTO.setMyBuildId(myBuildId);
                    scriptDTO.setOppBuildId(oppBuildId);
                    scriptDTO.setResult((String) script.get("resultType"));
                    scriptDTO.setContent((String) script.get("content"));
                    scriptDAO.insertScript(scriptDTO);
                }
            }
            result.put("success", true);
            result.put("message", "저장 완료");
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "저장 실패: " + e.getMessage());
        }
        return result;
    }

    // ⭐ 추가: 상성 불러오기 API
    @GetMapping("/script/matchup/load")
    @ResponseBody
    public Map<String, Object> loadBuildMatchup(@RequestParam("buildA") int buildA, @RequestParam("buildB") int buildB, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        if (!isAdmin(session)) { result.put("success", false); return result; }
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("buildA", buildA);
            params.put("buildB", buildB);
            String status = adminDAO.getBuildMatchup(params);
            result.put("success", true);
            result.put("status", status != null ? status : "NORMAL");
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
        }
        return result;
    }

    // ⭐ 추가: 상성 양방향 저장 API
    @Transactional
    @PostMapping("/script/matchup/save")
    @ResponseBody
    public Map<String, Object> saveBuildMatchup(@RequestBody Map<String, Object> params, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        if (!isAdmin(session)) { result.put("success", false); return result; }
        try {
            int buildA = Integer.parseInt(params.get("buildA").toString());
            int buildB = Integer.parseInt(params.get("buildB").toString());
            String status = (String) params.get("status");

            if (buildA == buildB) {
                result.put("success", false); result.put("message", "동일 빌드는 상성을 설정할 수 없습니다."); return result;
            }

            // 역상성 자동 계산 (A가 GOOD이면 B는 BAD)
            String reverseStatus = "NORMAL";
            if ("GOOD".equals(status)) reverseStatus = "BAD";
            else if ("BAD".equals(status)) reverseStatus = "GOOD";

            // A 기준 저장
            Map<String, Object> p1 = new HashMap<>();
            p1.put("buildA", buildA); p1.put("buildB", buildB); p1.put("status", status);
            adminDAO.saveBuildMatchup(p1);

            // B 기준 반전 저장
            Map<String, Object> p2 = new HashMap<>();
            p2.put("buildA", buildB); p2.put("buildB", buildA); p2.put("status", reverseStatus);
            adminDAO.saveBuildMatchup(p2);

            result.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    // ===================== ENTITY =====================

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
    
 // ============================================================
    //  AdminController.java 에 아래 메서드들을 붙여넣으세요.
    //  import 추가 필요: dto.pve.MapPointDTO
    // ============================================================

    // ===================== MAP =====================

    /** 맵 관리 페이지 */
    @GetMapping("/map/manage")
    public String mapManagePage(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/pve/lobby";

        List<Map<String, Object>> maps = adminDAO.findAllMapsDetail();

        StringBuilder mapJson = new StringBuilder("[");
        for (int i = 0; i < maps.size(); i++) {
            Map<String, Object> m = maps.get(i);
            if (i > 0) mapJson.append(",");
            mapJson.append("{")
                .append("\"mapId\":\"").append(je((String) m.get("MAPID")  != null ? (String) m.get("MAPID")  : (String) m.get("mapId"))).append("\",")
                .append("\"mapName\":\"").append(je((String) m.getOrDefault("MAPNAME", m.get("mapName")))).append("\",")
                .append("\"description\":\"").append(je((String) m.getOrDefault("DESCRIPTION", m.getOrDefault("description", "")))).append("\",")
                .append("\"mapImgUrl\":").append(m.getOrDefault("MAPIMGURL", m.get("mapImgUrl")) != null
                    ? "\"" + je((String) m.getOrDefault("MAPIMGURL", m.get("mapImgUrl"))) + "\""
                    : "null").append(",")
                .append("\"winRateT\":").append(m.getOrDefault("WINRATET", m.getOrDefault("winRateT", 50))).append(",")
                .append("\"winRateP\":").append(m.getOrDefault("WINRATEP", m.getOrDefault("winRateP", 50))).append(",")
                .append("\"winRateZ\":").append(m.getOrDefault("WINRATEZ", m.getOrDefault("winRateZ", 50)))
                .append("}");
        }
        mapJson.append("]");

        model.addAttribute("mapJson", mapJson.toString());
        return "admin/mapManage";
    }

    /** 맵 이미지 업로드 */
    @PostMapping("/map/upload-image")
    @ResponseBody
    public Map<String, Object> uploadMapImage(
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
            String uploadDir = request.getServletContext().getRealPath("/resources/image/maps");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            file.transferTo(new File(dir, saveName));
            String url = request.getContextPath() + "/image/maps/" + saveName;
            res.put("success", true);
            res.put("url", url);
        } catch (IOException e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", "업로드 실패: " + e.getMessage());
        }
        return res;
    }

    /** 맵 등록 */
    @PostMapping("/map/create")
    @ResponseBody
    public Map<String, Object> createMap(
            @RequestBody Map<String, Object> body,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            String mapId = "MAP_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase();
            Map<String, Object> params = new HashMap<>();
            params.put("mapId",       mapId);
            params.put("mapName",     body.get("mapName"));
            params.put("description", body.getOrDefault("description", ""));
            params.put("mapImgUrl",   body.get("mapImgUrl"));
            params.put("winRateT",    body.getOrDefault("winRateT", 50.0));
            params.put("winRateP",    body.getOrDefault("winRateP", 50.0));
            params.put("winRateZ",    body.getOrDefault("winRateZ", 50.0));
            adminDAO.insertMap(params);
            res.put("success", true);
            res.put("mapId",  mapId);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    /** 맵 수정 */
    @PostMapping("/map/update")
    @ResponseBody
    public Map<String, Object> updateMap(
            @RequestBody Map<String, Object> body,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            adminDAO.updateMap(body);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    /** 맵 삭제 */
    @PostMapping("/map/delete")
    @ResponseBody
    public Map<String, Object> deleteMap(
            @RequestBody Map<String, Object> body,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            String mapId = (String) body.get("mapId");
            adminDAO.deleteMapPointsByMapId(mapId);
            adminDAO.deleteMap(mapId);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    /** 특정 맵의 지점 목록 조회 */
    @GetMapping("/map/points")
    @ResponseBody
    public Map<String, Object> getMapPoints(
            @RequestParam("mapId") String mapId,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); return res; }
        List<dto.pve.MapPointDTO> points = adminDAO.findPointsByMapId(mapId);
        res.put("success", true);
        res.put("points", points);
        return res;
    }

    /** 지점 저장 (등록 또는 수정) */
    @PostMapping("/map/point/save")
    @ResponseBody
    public Map<String, Object> saveMapPoint(
            @RequestBody dto.pve.MapPointDTO dto,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            if (dto.getPointId() > 0) {
                adminDAO.updateMapPoint(dto);
            } else {
                adminDAO.insertMapPoint(dto);
            }
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    /** 지점 삭제 */
    @PostMapping("/map/point/delete")
    @ResponseBody
    public Map<String, Object> deleteMapPoint(
            @RequestBody Map<String, Object> body,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (!isAdmin(session)) { res.put("success", false); res.put("message", "권한 없음"); return res; }
        try {
            int pointId = toInt(body.get("pointId"));
            adminDAO.deleteMapPoint(pointId);
            res.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

}