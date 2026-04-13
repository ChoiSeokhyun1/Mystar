package controller.Main;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Arrays;
import java.util.Comparator;
import java.util.stream.Collectors;
import java.lang.reflect.Type;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import dao.pack.PackContentDAO;
import dao.pack.PackDAO;
import dao.player.PlayerDAO;
import dao.user.UserDAO;
import dao.player.OwnedPlayerDAO;
import dao.record.MatchRecordDAO;
import dao.pve.BattleSessionDAO;
import dao.pve.PveSubstageDAO;
import dto.mission.UserDailyMissionDTO;
import dto.pack.PackContentDTO;
import dto.pack.PackDTO;
import dto.player.PlayerDTO;
import dto.player.OwnedPlayerDTO;
import dto.user.UserDTO;
import dto.player.OwnedPlayerInfoDTO;
import dto.record.MatchRecordDTO;
import dto.record.PlayerRecordSummaryDTO;
import dto.pve.PveStageMapDTO;
import dto.pve.PveSubstageDTO;
import dto.pve.BuildDTO;
import dto.pve.PveOpponentInfoDTO;
import dto.pve.BattleProgressDTO;
import dto.pve.BattleSessionDTO;
import dto.pve.BattleFighterDTO;

import service.gacha.GachaService;
import service.mission.DailyMissionService;
import service.user.LoginService;
import service.entry.PveEntryService;
import service.pve.PveScenarioService;
import service.pve.PveSubstageService;
import org.springframework.dao.DataIntegrityViolationException;
import service.pve.BuildService;
import service.pve.PveBattleService;


@Controller
public class MainController {

    @Autowired private LoginService loginService;
    @Autowired private PackDAO packDAO;
    @Autowired private PackContentDAO packContentDAO;
    @Autowired private PlayerDAO playerDAO;
    @Autowired private GachaService gachaService;
    @Autowired private UserDAO userDAO;
    @Autowired private OwnedPlayerDAO ownedPlayerDAO;
    @Autowired private MatchRecordDAO matchRecordDAO;
    @Autowired private PveEntryService pveEntryService;
    @Autowired private PveScenarioService pveScenarioService;
    @Autowired private PveSubstageService pveSubstageService;
    @Autowired private BuildService buildService;
    @Autowired private BattleSessionDAO battleSessionDAO;
    @Autowired private PveSubstageDAO pveSubstageDAO;
    @Autowired private PveBattleService pveBattleService;
    @Autowired private DailyMissionService dailyMissionService;

    private final Random rand = new Random();
    private final Gson gson = new Gson();

    public static class SetResult {
        private int setNumber;
        private int myOwnedPlayerSeq;
        private String myPlayerName;
        private int aiPlayerSeq;
        private String aiPlayerName;
        private boolean myWin;
        private Map<String, Object> statChanges;

        public SetResult(int setNumber, int myOwnedPlayerSeq, String myPlayerName,
                         int aiPlayerSeq, String aiPlayerName, boolean myWin) {
            this.setNumber = setNumber;
            this.myOwnedPlayerSeq = myOwnedPlayerSeq;
            this.myPlayerName = myPlayerName;
            this.aiPlayerSeq = aiPlayerSeq;
            this.aiPlayerName = aiPlayerName;
            this.myWin = myWin;
            this.statChanges = new HashMap<>();
        }

        public int getSetNumber() { return setNumber; }
        public int getMyOwnedPlayerSeq() { return myOwnedPlayerSeq; }
        public String getMyPlayerName() { return myPlayerName; }
        public int getAiPlayerSeq() { return aiPlayerSeq; }
        public String getAiPlayerName() { return aiPlayerName; }
        public boolean isMyWin() { return myWin; }
        public Map<String, Object> getStatChanges() { return statChanges; }
        public void setStatChanges(Map<String, Object> statChanges) { this.statChanges = statChanges; }
        public void setMyWin(boolean myWin) { this.myWin = myWin; }
    }

    // ========================================
    // 1. 메인, 로그인, 로그아웃
    // ========================================
    @GetMapping("/")
    public String mainPage(HttpSession session) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        return "redirect:/mode-select";
    }

    @GetMapping("/mode-select")
    public String modeSelectPage(HttpSession session) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        return "modeSelect";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    @PostMapping("/login-process")
    public String loginProcess(@RequestParam("username") String userId,
                               @RequestParam("password") String userPw,
                               HttpSession session, RedirectAttributes rttr) {
        UserDTO userToLogin = new UserDTO();
        userToLogin.setUserId(userId);
        userToLogin.setUserPw(userPw);
        UserDTO loginUser = loginService.login(userToLogin, session);
        if (loginUser != null) {
            try {
                dailyMissionService.getUserMissionsToday(loginUser.getUserId());
            } catch (Exception e) {
                System.err.println("일일 미션 초기화 실패: " + e.getMessage());
            }
            return "redirect:/mode-select";
        } else {
            rttr.addFlashAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "redirect:/login";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        loginService.logout(session);
        return "redirect:/login";
    }

    // ========================================
    // 2. 가챠 시스템
    // ========================================
    @GetMapping("/gacha")
    public String gachaPage(HttpSession session, Model model) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";

        List<PackDTO> packList = packDAO.selectAvailablePacks();
        model.addAttribute("packList", packList);

        Map<Integer, PackDTO> allPackDetails = new HashMap<>();
        Map<Integer, List<PlayerDTO>> allFeaturedPlayers = new HashMap<>();
        List<String> rarityOrder = Arrays.asList("UR", "SSR", "SR", "R", "N");

        if (packList != null && !packList.isEmpty()) {
            for (PackDTO packStub : packList) {
                int packSeq = packStub.getPackSeq();
                PackDTO fullPackData = packDAO.selectPackBySeq(packSeq);
                if (fullPackData != null) {
                    allPackDetails.put(packSeq, fullPackData);
                    List<PackContentDTO> contents = packContentDAO.selectPackContentsByPackSeq(packSeq);
                    List<PlayerDTO> featuredPlayers = getFeaturedPlayersFromContents(contents, 100);
                    featuredPlayers.sort(Comparator.comparingInt(player -> {
                        String rarity = (player.getRarity() == null) ? "N" : player.getRarity().toUpperCase();
                        int index = rarityOrder.indexOf(rarity);
                        return (index == -1) ? rarityOrder.size() : index;
                    }));
                    allFeaturedPlayers.put(packSeq, featuredPlayers);
                }
            }
            PackDTO defaultPack = allPackDetails.get(packList.get(0).getPackSeq());
            if (defaultPack != null) model.addAttribute("defaultSelectedPack", defaultPack);
            model.addAttribute("defaultFeaturedPlayers", allFeaturedPlayers.get(packList.get(0).getPackSeq()));
        }
        model.addAttribute("allPackDetailsJson", gson.toJson(allPackDetails));
        model.addAttribute("allFeaturedPlayersJson", gson.toJson(allFeaturedPlayers));
        return "gacha";
    }

    @PostMapping("/gacha/draw")
    @ResponseBody
    public Map<String, Object> drawPlayer(@RequestParam("packSeq") int packSeq, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("error", "not_logged_in"); return response; }
        try {
            PlayerDTO drawnPlayer = gachaService.drawSinglePlayer(loginUser.getUserId(), packSeq);
            if (drawnPlayer != null) {
                UserDTO updatedUser = userDAO.selectUserCurrency(loginUser.getUserId());
                loginUser.setCrystal(updatedUser.getCrystal());
                session.setAttribute("loginUser", loginUser);
                response.put("updatedCurrency", updatedUser);
                response.put("player", drawnPlayer);
                response.put("success", true);
                
                try {
                    dailyMissionService.incrementMissionProgress(loginUser.getUserId(), "GACHA", 1);
                } catch (Exception e) {
                    System.err.println("가챠 미션 업데이트 실패: " + e.getMessage());
                }
            } else {
                response.put("success", false);
                response.put("message", "재화가 부족하거나 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "뽑기 중 오류가 발생했습니다.");
        }
        return response;
    }

    // ========================================
    // 3. 선수단 보기
    // ========================================
    @GetMapping("/my-team")
    public String myTeamPage(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/login";
        try {
            List<OwnedPlayerInfoDTO> playerList = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
            model.addAttribute("myPlayerList", playerList);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("myPlayerList", new ArrayList<>());
            model.addAttribute("errorMessage", "선 목록을 불러오는 데 실패했습니다.");
        }
        return "myTeam";
    }

    @GetMapping("/my-team/details")
    @ResponseBody
    public Map<String, Object> getPlayerDetailsAndRecords(@RequestParam("seq") int ownedPlayerSeq, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        if (session.getAttribute("loginUser") == null) { response.put("error", "not_logged_in"); return response; }
        try {
            OwnedPlayerInfoDTO playerDetails = ownedPlayerDAO.selectOwnedPlayerDetails(ownedPlayerSeq);
            if (playerDetails == null) { response.put("success", false); return response; }

            PlayerRecordSummaryDTO summary = matchRecordDAO.selectRecordSummary(ownedPlayerSeq);
            if (summary == null) summary = new PlayerRecordSummaryDTO();
            if (summary.getGamesPlayed() > 0) {
                double winRate = (double) summary.getWins() / summary.getGamesPlayed() * 100;
                summary.setWinRate(Math.round(winRate * 10.0) / 10.0);
            } else {
                summary.setWinRate(0.0);
            }
            List<MatchRecordDTO> recentMatches = matchRecordDAO.selectRecentMatches(ownedPlayerSeq, 10);
            if (recentMatches == null) recentMatches = new ArrayList<>();

            response.put("success", true);
            response.put("details", playerDetails);
            response.put("summary", summary);
            response.put("matches", recentMatches);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "선수 정보를 불러오는 중 오류가 발생했습니다.");
        }
        return response;
    }

    @GetMapping("/player/details")
    @ResponseBody
    public Map<String, Object> getPlayerMasterDetails(@RequestParam("seq") int playerSeq, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        if (session.getAttribute("loginUser") == null) { response.put("error", "not_logged_in"); return response; }
        try {
            PlayerDTO playerDetails = playerDAO.selectPlayerBySeq(playerSeq);
            if (playerDetails != null) {
                response.put("success", true);
                response.put("details", playerDetails);
            } else {
                response.put("success", false);
                response.put("message", "선수 마스터 정보를 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "선수 정보를 불러오는 중 오류가 발생했습니다.");
        }
        return response;
    }

    // ========================================
    // 4. PVE 엔트리
    // ========================================
    @GetMapping("/my-team/entry")
    public String pveEntryPage(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/login";
        try {
            List<OwnedPlayerInfoDTO> allOwnedPlayers = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
            model.addAttribute("allOwnedPlayers", allOwnedPlayers);
            List<OwnedPlayerInfoDTO> pveEntryPlayers = pveEntryService.getPveEntry(loginUser.getUserId());
            model.addAttribute("pveEntryPlayers", pveEntryPlayers);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "엔트리 정보를 불러오는 데 실패했습니다.");
            model.addAttribute("allOwnedPlayers", new ArrayList<>());
            model.addAttribute("pveEntryPlayers", new ArrayList<>());
        }
        return "pveEntry";
    }

    @PostMapping("/my-team/entry/save")
    @ResponseBody
    public Map<String, Object> savePveEntry(@RequestBody List<Integer> entryPlayerSeqList, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("error", "not_logged_in"); return response; }
        try {
            boolean success = pveEntryService.updatePveEntry(loginUser.getUserId(), entryPlayerSeqList);
            response.put("success", success);
            response.put("message", success ? "엔트리가 저장되었습니다." : "엔트리 저장에 실패했습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "엔트리 저장 중 오류가 발생했습니다.");
        }
        return response;
    }

    // ========================================
    // 5. PVE 로비 / 시나리오 / 스테이지
    // ========================================
    @GetMapping("/pve/lobby")
    public ModelAndView showPveLobbyPage(ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();

        Map<Integer, String> stageStatusMap = pveScenarioService.getStageStatusMapForUser(userId);
        Integer maxStageFromDb = pveSubstageDAO.findMaxStageLevel();
        int maxStage = (maxStageFromDb != null && maxStageFromDb > 0) ? maxStageFromDb : 1;
        long clearedCount = stageStatusMap.values().stream().filter("CLEARED"::equals).count();

        Map<Integer, Double> stageProgressMap = new HashMap<>();
        for (Map.Entry<Integer, String> entry : stageStatusMap.entrySet()) {
            int stageLevel = entry.getKey();
            String status = entry.getValue();
            if ("CLEARED".equals(status)) {
                stageProgressMap.put(stageLevel, 100.0);
            } else if ("IN_PROGRESS".equals(status)) {
                try {
                    List<dto.pve.PveSubstageDTO> allSubs = pveSubstageDAO.findSubstagesByStageLevel(stageLevel);
                    int total = (allSubs != null) ? allSubs.size() : 0;
                    if (total > 0) {
                        Map<String, Object> params = new HashMap<>();
                        params.put("userId", userId);
                        params.put("stageLevel", stageLevel);
                        List<dto.pve.UserPveSubstageProgressDTO> cleared = pveSubstageDAO.findClearedSubstagesForUser(params);
                        int clearedSubs = (cleared != null) ? cleared.size() : 0;
                        double pct = Math.round((clearedSubs * 1000.0 / total)) / 10.0;
                        stageProgressMap.put(stageLevel, pct);
                    } else {
                        stageProgressMap.put(stageLevel, 0.0);
                    }
                } catch (Exception e) {
                    stageProgressMap.put(stageLevel, 0.0);
                }
            } else {
                stageProgressMap.put(stageLevel, 0.0);
            }
        }

        int playerCount = 0;
        try {
            List<OwnedPlayerInfoDTO> players = ownedPlayerDAO.selectOwnedPlayersByUserId(userId);
            playerCount = players != null ? players.size() : 0;
        } catch (Exception e) { /* 무시 */ }

        List<BuildDTO> top3Builds = new ArrayList<>();
        try {
            List<BuildDTO> allBuilds = buildService.getBuildsByUserId(userId);
            if (allBuilds != null) {
                top3Builds = allBuilds.stream().limit(3).collect(Collectors.toList());
            }
        } catch (Exception e) { /* 무시 */ }

        dto.record.PlayerStatRankDTO mostPlayed  = null;
        dto.record.PlayerStatRankDTO bestWinRate = null;
        dto.record.PlayerStatRankDTO mostWins    = null;
        try {
            mostPlayed  = matchRecordDAO.selectMostPlayedPlayer(userId);
            bestWinRate = matchRecordDAO.selectBestWinRatePlayer(userId);
            mostWins    = matchRecordDAO.selectMostWinsPlayer(userId);
        } catch (Exception e) { /* 무시 */ }

        mv.addObject("stageStatusMap",   stageStatusMap);
        mv.addObject("stageProgressMap", stageProgressMap);
        mv.addObject("maxStageLevel",    maxStage);
        mv.addObject("clearedCount",     clearedCount);
        mv.addObject("totalStage",       maxStage);
        mv.addObject("playerCount",      playerCount);
        mv.addObject("top3Builds",       top3Builds);
        mv.addObject("mostPlayed",       mostPlayed);
        mv.addObject("bestWinRate",      bestWinRate);
        mv.addObject("mostWins",         mostWins);
        mv.setViewName("pveLobby");
        return mv;
    }


    @GetMapping("/pve/stage")
    public ModelAndView showPveStageDetailPage(@RequestParam("level") int level, ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();
        Map<Integer, String> statusMap = pveScenarioService.getStageStatusMapForUser(userId);
        if (!"IN_PROGRESS".equals(statusMap.getOrDefault(level, "LOCKED"))) {
            mv.setViewName("redirect:/pve/lobby");
            return mv;
        }
        List<Map<String, Object>> subStages = pveSubstageService.getSubstageListWithStatus(userId, level);
        mv.addObject("mainStageLevel", level);
        mv.addObject("subStageList", subStages);
        mv.setViewName("pveStageDetail");
        return mv;
    }

    @GetMapping("/pve/stage/opponents")
    @ResponseBody
    public Map<String, Object> getOpponentsForRound(
            @RequestParam("level") int level,
            @RequestParam("subLevel") int subLevel,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("error", "unauthorized"); return result; }
        try {
            List<PveOpponentInfoDTO> players = pveSubstageService.getOpponentEntryForSubstage(level, subLevel);
            String teamName = "AI Team";
            dto.pve.PveSubstageDTO details = pveSubstageService.getSubstageDetails(level, subLevel);
            if (details != null && details.getOpponentTeamName() != null) {
                teamName = details.getOpponentTeamName();
            }
            result.put("teamName", teamName);
            result.put("players", players != null ? players : new ArrayList<>());
        } catch (Exception e) {
            result.put("error", e.getMessage());
            result.put("players", new ArrayList<>());
        }
        return result;
    }

    // ========================================
    // 6. PVE 전투 준비
    // ========================================
    @GetMapping("/pve/battle")
    public ModelAndView showPveBattleSetupPage(@RequestParam("level") int stageLevel,
                                               @RequestParam("subLevel") int subLevel,
                                               ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);

        BattleSessionDTO activeBattle = battleSessionDAO.selectActiveBattle(params);
        if (activeBattle != null) {
            mv.setViewName("redirect:/pve/battle/result?level=" + stageLevel + "&subLevel=" + subLevel);
            return mv;
        }

        try {
            List<Map<String, Object>> subStageList = pveSubstageService.getSubstageListWithStatus(userId, stageLevel);
            boolean isCleared = subStageList.stream()
                .anyMatch(s -> s.get("subLevel") != null
                    && Integer.parseInt(s.get("subLevel").toString()) == subLevel
                    && "CLEARED".equals(s.get("status")));
            if (isCleared) {
                mv.setViewName("redirect:/pve/stage?level=" + stageLevel);
                return mv;
            }
        } catch (Exception e) { /* 무시 */ }
        if (session.getAttribute("currentBattleId") != null) cleanUpPveSession(session);

        String myTeamName = (loginUser.getTeamName() != null) ? loginUser.getTeamName() : loginUser.getUserNick();
        PveSubstageDTO substageDetails = pveSubstageService.getSubstageDetails(stageLevel, subLevel);
        String opponentTeamName = (substageDetails != null) ? substageDetails.getOpponentTeamName() : "AI Team";

        List<PveStageMapDTO> mapList = pveSubstageService.getMapsForSubstage(stageLevel, subLevel);
        if (mapList == null) mapList = new ArrayList<>();
        List<OwnedPlayerInfoDTO> myEntryList = pveEntryService.getPveEntry(userId);
        if (myEntryList == null) myEntryList = new ArrayList<>();
        List<PveOpponentInfoDTO> opponentEntryList = pveSubstageService.getOpponentEntryForSubstage(stageLevel, subLevel);

        Map<Integer, PveOpponentInfoDTO> aiPlayerMap = new HashMap<>();
        if (opponentEntryList != null) {
            for (PveOpponentInfoDTO aiPlayer : opponentEntryList) {
                if (aiPlayer.getSetNumber() > 0) aiPlayerMap.put(aiPlayer.getSetNumber(), aiPlayer);
            }
        }

        try {
            List<BuildDTO> allBuilds = buildService.getAllBuilds();
            List<BuildDTO> myBuilds = new ArrayList<>();
            
            if (allBuilds != null) {
                myBuilds = allBuilds.stream()
                    .filter(b -> "SYSTEM".equalsIgnoreCase(b.getUserId()) 
                              || "admin".equalsIgnoreCase(b.getUserId())
                              || userId.equals(b.getUserId()))
                    .collect(Collectors.toList());
            }
            
            ObjectMapper om = new ObjectMapper();
            mv.addObject("myBuildsJson", om.writeValueAsString(myBuilds));
        } catch (Exception e) {
            e.printStackTrace();
            mv.addObject("myBuildsJson", "[]");
        }

        mv.addObject("stageLevel", stageLevel);
        mv.addObject("subLevel", subLevel);
        mv.addObject("myTeamName", myTeamName);
        mv.addObject("opponentTeamName", opponentTeamName);
        mv.addObject("mapList", mapList);
        mv.addObject("myEntryList", myEntryList);
        mv.addObject("opponentEntryList", opponentEntryList);
        mv.addObject("aiPlayerMap", aiPlayerMap);
        mv.setViewName("pveMatchSetup");
        return mv;
    }

    // ========================================
    // 7. 빌드 관리
    // ========================================
    @GetMapping("/build/manage")
    public String showBuildManagement(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/login";
        try {
            List<BuildDTO> myBuilds = buildService.getBuildsByUserId(loginUser.getUserId());
            model.addAttribute("myBuilds", myBuilds != null ? myBuilds : new ArrayList<BuildDTO>());
        } catch (Exception e) {
            model.addAttribute("myBuilds", new ArrayList<BuildDTO>());
        }
        model.addAttribute("pageTitle", "전략 관리");
        return "buildManagement";
    }

    @PostMapping("/build/create")
    @ResponseBody
    public Map<String, Object> createBuild(@RequestBody BuildDTO buildDto, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("success", false); response.put("message", "로그인이 필요합니다."); return response; }
        try {
            buildDto.setUserId(loginUser.getUserId());
            buildService.createBuild(buildDto);
            response.put("success", true);
        } catch (DataIntegrityViolationException e) {
            response.put("success", false);
            response.put("message", "같은 종족에 동일한 이름의 전략이 이미 존재합니다.");
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "빌드 생성 실패: " + e.getMessage());
        }
        return response;
    }

    @PostMapping("/build/update")
    @ResponseBody
    public Map<String, Object> updateBuild(@RequestBody BuildDTO buildDto, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("success", false); return response; }
        try {
            buildDto.setUserId(loginUser.getUserId());
            buildService.modifyBuild(buildDto);
            response.put("success", true);
        } catch (DataIntegrityViolationException e) {
            response.put("success", false);
            response.put("message", "같은 종족에 동일한 이름의 전략이 이미 존재합니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "빌드 수정 실패: " + e.getMessage());
        }
        return response;
    }

    // =====================================================
    // 훈련 시스템
    // =====================================================
    @GetMapping("/pve/train")
    public ModelAndView showTrainPage(ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        UserDTO currency = userDAO.selectUserCurrency(loginUser.getUserId());
        int trainPoint = (currency != null) ? currency.getTrainPoint() : 0;
        mv.addObject("trainPoint", trainPoint);
        List<OwnedPlayerInfoDTO> players = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
        mv.addObject("players", players != null ? players : new ArrayList<>());
        mv.setViewName("pveTrain");
        return mv;
    }

    @PostMapping("/pve/train/use")
    @ResponseBody
    public Map<String, Object> useTrainPoint(
            @RequestParam("ownedPlayerSeq") int ownedPlayerSeq,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { res.put("success", false); res.put("message", "로그인 필요"); return res; }

        String userId = loginUser.getUserId();
        UserDTO currency = userDAO.selectUserCurrency(userId);
        if (currency == null || currency.getTrainPoint() < 1) {
            res.put("success", false); res.put("message", "훈련 포인트가 부족합니다."); return res;
        }
        OwnedPlayerDTO player = ownedPlayerDAO.selectOwnedPlayer(ownedPlayerSeq);
        if (player == null || !userId.equals(player.getUserId())) {
            res.put("success", false); res.put("message", "선수를 찾을 수 없습니다."); return res;
        }

        Map<String, Object> tpParams = new HashMap<>();
        tpParams.put("userId", userId);
        tpParams.put("amount", -1);
        userDAO.updateUserTrainPoint(tpParams);

        int a  = player.getCurrentAttack()  == 0 ? 50 : player.getCurrentAttack();
        int d  = player.getCurrentDefense() == 0 ? 50 : player.getCurrentDefense();
        int ma = player.getCurrentMacro()   == 0 ? 50 : player.getCurrentMacro();
        int mi = player.getCurrentMicro()   == 0 ? 50 : player.getCurrentMicro();
        int l  = player.getCurrentLuck()    == 0 ? 50 : player.getCurrentLuck();

        int[] inc = new int[5];
        for (int i = 0; i < 3; i++) inc[rand.nextInt(5)]++;

        player.setCurrentAttack(a  + inc[0]);
        player.setCurrentDefense(d + inc[1]);
        player.setCurrentMacro(ma  + inc[2]);
        player.setCurrentMicro(mi  + inc[3]);
        player.setCurrentLuck(l    + inc[4]);
        ownedPlayerDAO.updatePlayerStats(player);
        
        try {
            dailyMissionService.incrementMissionProgress(userId, "TRAIN", 1);
        } catch (Exception e) {
            System.err.println("훈련 미션 업데이트 실패: " + e.getMessage());
        }

        res.put("success", true);
        res.put("attackInc",  inc[0]); res.put("defenseInc", inc[1]);
        res.put("macroInc",   inc[2]); res.put("microInc",   inc[3]); res.put("luckInc", inc[4]);
        res.put("afterAttack",  player.getCurrentAttack());
        res.put("afterDefense", player.getCurrentDefense());
        res.put("afterMacro",   player.getCurrentMacro());
        res.put("afterMicro",   player.getCurrentMicro());
        res.put("afterLuck",    player.getCurrentLuck());
        res.put("remainPoint",  currency.getTrainPoint() - 1);
        return res;
    }

    @GetMapping("/build/detail")
    @ResponseBody
    public Map<String, Object> getBuildDetail(@RequestParam("id") int buildId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("success", false); return response; }
        try {
            BuildDTO build = buildService.getBuildById(buildId);
            if (build != null && loginUser.getUserId().equals(build.getUserId())) {
                response.put("success", true);
                response.put("build", build);
            } else {
                response.put("success", false);
                response.put("message", "빌드를 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "서버 오류.");
        }
        return response;
    }

    @PostMapping("/build/delete")
    @ResponseBody
    public Map<String, Object> deleteBuild(@RequestBody Map<String, Integer> payload, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { response.put("success", false); return response; }
        try {
            int buildId = payload.get("buildId");
            BuildDTO build = buildService.getBuildById(buildId);
            if (build != null && loginUser.getUserId().equals(build.getUserId())) {
                buildService.removeBuild(buildId);
                response.put("success", true);
            } else {
                response.put("success", false);
                response.put("message", "권한이 없거나 빌드를 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "서버 오류.");
        }
        return response;
    }

    // ========================================
    // 8. PVE 배틀 시뮬레이션
    // ========================================
    @PostMapping("/pve/battle/start")
    public ModelAndView startPveBattle(
            @RequestParam("level") int stageLevel,
            @RequestParam("subLevel") int subLevel,
            @RequestParam("set1Player") int set1OwnedSeq,
            @RequestParam("set2Player") int set2OwnedSeq,
            @RequestParam("set3Player") int set3OwnedSeq,
            @RequestParam("set4Player") int set4OwnedSeq,
            @RequestParam("set5Player") int set5OwnedSeq,
            @RequestParam(value = "set1Build", defaultValue = "0") int set1Build,
            @RequestParam(value = "set2Build", defaultValue = "0") int set2Build,
            @RequestParam(value = "set3Build", defaultValue = "0") int set3Build,
            @RequestParam(value = "set4Build", defaultValue = "0") int set4Build,
            @RequestParam(value = "set5Build", defaultValue = "0") int set5Build,
            ModelAndView mv, HttpSession session) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
        String userId = loginUser.getUserId();

        try {
            Map<String, Object> checkParams = new HashMap<>();
            checkParams.put("userId", userId);
            checkParams.put("stageLevel", stageLevel);
            checkParams.put("subLevel", subLevel);
            BattleSessionDTO existingBattle = battleSessionDAO.selectActiveBattle(checkParams);
            if (existingBattle != null) {
                mv.setViewName("redirect:/pve/battle/result?level=" + stageLevel + "&subLevel=" + subLevel);
                return mv;
            }
        } catch (Exception e) { /* 조회 실패 시 새로 생성 허용 */ }

        int[] myPlayerOwnedSeqs = {set1OwnedSeq, set2OwnedSeq, set3OwnedSeq, set4OwnedSeq, set5OwnedSeq};
        int[] myBuildIds = {set1Build, set2Build, set3Build, set4Build, set5Build};
        Map<Integer, PveOpponentInfoDTO> aiPlayerMap = pveSubstageService.getOpponentMapForSubstage(stageLevel, subLevel);
        
        // ★ 맵 리스트를 넘겨서 맵 ID를 반영하도록 처리
        List<PveStageMapDTO> mapList = pveSubstageService.getMapsForSubstage(stageLevel, subLevel);

        try {
            Map<String, Object> creationResult = createNewMatchupList(
                userId, stageLevel, subLevel, myPlayerOwnedSeqs, myBuildIds, aiPlayerMap, mapList
            );
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> matchupList = (List<Map<String, Object>>) creationResult.get("matchupList");

            Map<String, Object> currentMatchup = matchupList.get(0);
            Map<String, Integer> myStats = extractStats(currentMatchup, "myPlayer");
            Map<String, Integer> aiStats = extractStats(currentMatchup, "aiPlayer");
            String myRace = (String) currentMatchup.get("myPlayerRace");
            String aiRace = (String) currentMatchup.get("aiPlayerRace");

            BuildDTO myBuildDto = (myBuildIds[0] > 0) ? buildService.getBuildById(myBuildIds[0]) : null;

            int aiBuildIdVal = safeInt(currentMatchup.get("aiBuildId"), 0);
            BuildDTO aiBuildDto = (aiBuildIdVal > 0) ? buildService.getBuildById(aiBuildIdVal) : null;

            String myPlayerName = (String) currentMatchup.getOrDefault("myPlayerName", "아군");
            String aiPlayerName = (String) currentMatchup.getOrDefault("aiPlayerName", "AI");
            
            String myCondition = (String) currentMatchup.getOrDefault("myPlayerCondition", "NORMAL");
            int myWinStreak = safeInt(currentMatchup.get("myPlayerWinStreak"), 0);
            String aiCondition = (String) currentMatchup.getOrDefault("aiPlayerCondition", "NORMAL");
            int aiWinStreak = safeInt(currentMatchup.get("aiPlayerWinStreak"), 0);

            Map<String, Object> firstMatchup = matchupList.get(0);
            firstMatchup.put("myAttack",  myStats.get("attack"));
            firstMatchup.put("myDefense", myStats.get("defense"));
            firstMatchup.put("myMacro",   myStats.get("macro"));
            firstMatchup.put("myMicro",   myStats.get("micro"));
            firstMatchup.put("myLuck",    myStats.get("luck"));
            firstMatchup.put("aiAttack",  aiStats.get("attack"));
            firstMatchup.put("aiDefense", aiStats.get("defense"));
            firstMatchup.put("aiMacro",   aiStats.get("macro"));
            firstMatchup.put("aiMicro",   aiStats.get("micro"));
            firstMatchup.put("aiLuck",    aiStats.get("luck"));
            firstMatchup.put("myRace",    myRace);
            firstMatchup.put("aiRace",    aiRace);
            firstMatchup.put("myBuild",   myBuildDto);
            firstMatchup.put("aiBuild",   aiBuildDto);
            firstMatchup.put("myCondition", myCondition);
            firstMatchup.put("myWinStreak", myWinStreak);
            firstMatchup.put("aiCondition", aiCondition);
            firstMatchup.put("aiWinStreak", aiWinStreak);
            
            boolean myWinFlag = pveBattleService.calculateWinResults(
                Collections.singletonList(firstMatchup)).get(0);

            // ★ 대본 시스템 폐기 — scriptLines 제거, ATB 엔진이 프론트에서 전투 진행
            List<String> scriptLines = Collections.emptyList();

            BattleSessionDTO newSession = new BattleSessionDTO();
            newSession.setUserId(userId);
            newSession.setStageLevel(stageLevel);
            newSession.setSubLevel(subLevel);
            newSession.setMatchupData(gson.toJson(matchupList));
            newSession.setStatus("IN_PROGRESS");
            newSession.setCurrentSet(1);
            newSession.setMyWins(0);
            newSession.setAiWins(0);
            
            Map<String, Object> scriptData = new HashMap<>();
            scriptData.put("lines",  scriptLines);
            scriptData.put("myWin",  myWinFlag);
            scriptData.put("myName", myPlayerName);
            scriptData.put("aiName", aiPlayerName);
            scriptData.put("mapId",  currentMatchup.get("mapId")); // ★ 맵 ID 프론트에 전달
            newSession.setGameStateData(gson.toJson(scriptData));
            
            List<SetResult> initialSetResults = (List<SetResult>) creationResult.get("setResults");
            newSession.setSetResultsData(gson.toJson(initialSetResults));
            battleSessionDAO.insertNewBattle(newSession);

            session.setAttribute("simulationMatchupList", matchupList);
            session.setAttribute("currentBattleId", "DB_BATTLE_ACTIVE");
            session.setAttribute("currentSet", 1);
            session.setAttribute("myWins", 0);
            session.setAttribute("aiWins", 0);
            session.setAttribute("setResults", creationResult.get("setResults"));

            mv.setViewName("redirect:/pve/battle/result?level=" + stageLevel + "&subLevel=" + subLevel);
        } catch (Exception e) {
            e.printStackTrace();
            mv.setViewName("redirect:/pve/lobby");
        }
        return mv;
    }

    @GetMapping("/pve/battle/result")
    public ModelAndView showPveBattleResult(@RequestParam("level") int stageLevel,
                                            @RequestParam("subLevel") int subLevel,
                                            ModelAndView mv, HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { mv.setViewName("redirect:/login"); return mv; }
 
        Map<String, Object> params = new HashMap<>();
        params.put("userId",     loginUser.getUserId());
        params.put("stageLevel", stageLevel);
        params.put("subLevel",   subLevel);
 
        BattleSessionDTO activeBattle = battleSessionDAO.selectActiveBattle(params);
        if (activeBattle == null) { mv.setViewName("redirect:/pve/lobby"); return mv; }
 
        Type type = new TypeToken<List<Map<String, Object>>>() {}.getType();
        List<Map<String, Object>> matchupList = gson.fromJson(activeBattle.getMatchupData(), type);
        int currentSet = activeBattle.getCurrentSet();
 
        // ★★★ 변경: 백엔드 시뮬레이션 실행 (기존 prepareBattleData 대체) ★★★
        Map<String, Object> simResult = pveBattleService.runBattleSimulation(
            loginUser.getUserId(), stageLevel, subLevel
        );
 
        // 초기 전투원 스탯 (좌표 포함) — JS renderSquadCards / setupFighterEntities 에 사용
        @SuppressWarnings("unchecked")
        List<BattleFighterDTO> battleFighters =
            (List<BattleFighterDTO>) simResult.get("fighters");
        String battleDataJson = gson.toJson(battleFighters);
 
        // 전투 타임라인 이벤트 JSON — JS playReplay(events) 에 사용
        String eventLogJson = (String) simResult.get("eventLogJson");
        if (eventLogJson == null || eventLogJson.isEmpty()) eventLogJson = "[]";
 
        mv.addObject("battleDataJson", battleDataJson);
        mv.addObject("eventLogJson",   eventLogJson);            // ★ 신규
        mv.addObject("simWinner",      simResult.get("winner")); // ★ 신규 (로그용)
 
        mv.addObject("stageLevel",  stageLevel);
        mv.addObject("subLevel",    subLevel);
        mv.addObject("replayJson",  "[]");   // 구버전 호환 유지 (미사용)
        mv.addObject("matchupList", matchupList);
        mv.addObject("currentSet",  currentSet);
        mv.addObject("myWins",      activeBattle.getMyWins());
        mv.addObject("aiWins",      activeBattle.getAiWins());
        mv.addObject("myTeamName",
            loginUser.getTeamName() != null ? loginUser.getTeamName() : loginUser.getUserNick());
 
        PveSubstageDTO substageDetails =
            pveSubstageService.getSubstageDetails(stageLevel, subLevel);
        mv.addObject("opponentTeamName",
            substageDetails != null ? substageDetails.getOpponentTeamName() : "AI Team");
 
        session.setAttribute("currentSet", currentSet);
        session.setAttribute("myWins",  activeBattle.getMyWins());
        session.setAttribute("aiWins",  activeBattle.getAiWins());
        session.setAttribute("simulationMatchupList", matchupList);
 
        if (session.getAttribute("setResults") == null) {
            String savedSetResults = activeBattle.getSetResultsData();
            if (savedSetResults != null && !savedSetResults.isEmpty()) {
                try {
                    Type srType = new TypeToken<List<SetResult>>() {}.getType();
                    List<SetResult> recovered = gson.fromJson(savedSetResults, srType);
                    session.setAttribute("setResults", recovered);
                } catch (Exception ignored) {}
            }
        }
 
        mv.setViewName("pveBattleSimulation");
        return mv;
    }

    @PostMapping("/pve/battle/finish")
    @ResponseBody
    public Map<String, Object> finishPveBattle(
            @RequestParam("level") int stageLevel,
            @RequestParam("subLevel") int subLevel,
            @RequestParam("winner") String winner,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        String userId = loginUser.getUserId();
        
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);

        BattleSessionDTO activeBattle = battleSessionDAO.selectActiveBattle(params);
        if (activeBattle == null) {
            response.put("success", false);
            response.put("message", "진행 중인 경기를 찾을 수 없습니다.");
            return response;
        }

        int currentSet = activeBattle.getCurrentSet();
        int myWins = activeBattle.getMyWins();
        int aiWins = activeBattle.getAiWins();
        boolean lastSetMyWin = "player".equals(winner);
        if (lastSetMyWin) myWins++; else aiWins++;

        Type listType = new TypeToken<List<Map<String, Object>>>() {}.getType();
        List<Map<String, Object>> matchupList = gson.fromJson(activeBattle.getMatchupData(), listType);
        int totalSets = matchupList.size();
        boolean isMatchOver = (myWins > totalSets / 2) || (aiWins > totalSets / 2) || (currentSet >= totalSets);

        @SuppressWarnings("unchecked")
        List<SetResult> setResults = (List<SetResult>) session.getAttribute("setResults");

        if (setResults == null) {
            String savedSetResults = activeBattle.getSetResultsData();
            if (savedSetResults != null && !savedSetResults.isEmpty()) {
                try {
                    Type srType = new TypeToken<List<SetResult>>() {}.getType();
                    setResults = gson.fromJson(savedSetResults, srType);
                    session.setAttribute("setResults", setResults);
                } catch (Exception e) { }
            }
            if (setResults == null) {
                setResults = new ArrayList<>();
                for (int i = 0; i < matchupList.size(); i++) {
                    Map<String, Object> m = matchupList.get(i);
                    setResults.add(new SetResult(
                        i + 1,
                        safeInt(m.get("myOwnedPlayerSeq"), 0),
                        (String) m.getOrDefault("myPlayerName", "N/A"),
                        safeInt(m.get("aiPlayerSeq"), 0),
                        (String) m.getOrDefault("aiPlayerName", "N/A"),
                        false
                    ));
                }
                session.setAttribute("setResults", setResults);
            }
        }

        if (setResults != null && currentSet <= setResults.size()) {
            SetResult completedSet = setResults.get(currentSet - 1);
            OwnedPlayerDTO player = ownedPlayerDAO.selectOwnedPlayer(completedSet.getMyOwnedPlayerSeq());
            if (player != null) {
                Map<String, Object> currentMatchup = matchupList.get(currentSet - 1);
                int usedBuildId = safeInt(currentMatchup.get("myBuildId"), 0);
                BuildDTO usedBuild = (usedBuildId > 0) ? buildService.getBuildById(usedBuildId) : null;

                int myTotal = safeInt(currentMatchup.get("myPlayerAttack"),  50)
                            + safeInt(currentMatchup.get("myPlayerDefense"), 50)
                            + safeInt(currentMatchup.get("myPlayerMacro"),   50)
                            + safeInt(currentMatchup.get("myPlayerMicro"),   50)
                            + safeInt(currentMatchup.get("myPlayerLuck"),    50);
                int aiTotal = safeInt(currentMatchup.get("aiPlayerAttack"),  50)
                            + safeInt(currentMatchup.get("aiPlayerDefense"), 50)
                            + safeInt(currentMatchup.get("aiPlayerMacro"),   50)
                            + safeInt(currentMatchup.get("aiPlayerMicro"),   50)
                            + safeInt(currentMatchup.get("aiPlayerLuck"),    50);

                Map<String, Object> changes = lastSetMyWin
                        ? applyBuildBasedStatIncrease(player, usedBuild, myTotal, aiTotal)
                        : applyRandomStatDecrease(player, myTotal, aiTotal);
                ownedPlayerDAO.updatePlayerStats(player);

                if (lastSetMyWin) {
                    player.setWinStreak(Math.min(player.getWinStreak() + 1, 5));
                } else {
                    player.setWinStreak(0);
                }
                ownedPlayerDAO.updateWinStreak(player);

                MatchRecordDTO record = new MatchRecordDTO();
                record.setOwnedPlayerSeq(completedSet.getMyOwnedPlayerSeq());
                record.setIsWin(lastSetMyWin ? "Y" : "N");
                record.setMatchDate(new java.util.Date());
                record.setMatchType("PVE");
                record.setMapName((String) currentMatchup.getOrDefault("mapName", "Fighting Spirit"));
                record.setOpponentName((String) currentMatchup.getOrDefault("aiPlayerName", "AI"));
                record.setOpponentRace((String) currentMatchup.getOrDefault("aiPlayerRace", "A"));
                matchRecordDAO.insertMatchRecord(record);

                if (usedBuildId > 0) {
                    try { buildService.recordBuildResult(usedBuildId, lastSetMyWin); } catch (Exception e) {}
                }

                completedSet.setMyWin(lastSetMyWin);
                completedSet.setStatChanges(changes);

                try {
                    Map<String, Object> srParams = new HashMap<>();
                    srParams.put("userId", userId);
                    srParams.put("stageLevel", stageLevel);
                    srParams.put("subLevel", subLevel);
                    srParams.put("setResultsData", gson.toJson(setResults));
                    battleSessionDAO.updateSetResultsData(srParams);
                } catch (Exception e) {}
            }
        }

        List<Map<String, Object>> playerChanges = new ArrayList<>();
        if (setResults != null) {
            for (int i = 0; i < currentSet; i++) {
                SetResult sr = setResults.get(i);
                if (sr.getStatChanges() != null && !sr.getStatChanges().isEmpty())
                    playerChanges.add(sr.getStatChanges());
            }
        }
        response.put("playerChanges", playerChanges);

        if (isMatchOver) {
            boolean finalVictory = myWins > aiWins;
            if (finalVictory) {
                try {
                    params.put("myWins", myWins);
                    params.put("aiWins", aiWins);
                    battleSessionDAO.completePveBattleSession(params);
                    pveSubstageService.clearSubstage(userId, stageLevel, subLevel);
                    response.put("message", "승리! 전체 매치를 승리하여 모든 선수가 성장했습니다.");
                    
                    try {
                        dailyMissionService.incrementMissionProgress(userId, "PVE_WIN", 1);
                        if (myWins == 3 && aiWins == 0) {
                            dailyMissionService.incrementMissionProgress(userId, "PVE_PERFECT", 1);
                        }
                    } catch (Exception e) {}
                } catch (Exception e) {}
            } else {
                battleSessionDAO.deletePveBattleSession(params);
                response.put("message", "패배했습니다. 선수들의 사기가 떨어졌습니다.");
            }
            response.put("victory", finalVictory);
            response.put("myWins", myWins);
            response.put("aiWins", aiWins);
            cleanUpPveSession(session);
        } else {
            int nextSet = currentSet + 1;
            try {
                Map<String, Object> nextMatchup = matchupList.get(nextSet - 1);
                
                // ★ 다음 라운드를 위한 데이터 재세팅 및 대본(Script) 새로 생성 버그 수정
                Map<String, Integer> myStats = extractStats(nextMatchup, "myPlayer");
                Map<String, Integer> aiStats = extractStats(nextMatchup, "aiPlayer");
                String myRace = (String) nextMatchup.get("myPlayerRace");
                String aiRace = (String) nextMatchup.get("aiPlayerRace");

                int myBuildIdVal = safeInt(nextMatchup.get("myBuildId"), 0);
                BuildDTO myBuildDto = (myBuildIdVal > 0) ? buildService.getBuildById(myBuildIdVal) : null;

                int aiBuildIdVal = safeInt(nextMatchup.get("aiBuildId"), 0);
                BuildDTO aiBuildDto = (aiBuildIdVal > 0) ? buildService.getBuildById(aiBuildIdVal) : null;

                String myPName = (String) nextMatchup.getOrDefault("myPlayerName", "아군");
                String aiPName = (String) nextMatchup.getOrDefault("aiPlayerName", "AI");
                String myCondition = (String) nextMatchup.getOrDefault("myPlayerCondition", "NORMAL");
                int myWinStreak = safeInt(nextMatchup.get("myPlayerWinStreak"), 0);
                String aiCondition = (String) nextMatchup.getOrDefault("aiPlayerCondition", "NORMAL");
                int aiWinStreak = safeInt(nextMatchup.get("aiPlayerWinStreak"), 0);

                nextMatchup.put("myAttack",  myStats.get("attack"));
                nextMatchup.put("myDefense", myStats.get("defense"));
                nextMatchup.put("myMacro",   myStats.get("macro"));
                nextMatchup.put("myMicro",   myStats.get("micro"));
                nextMatchup.put("myLuck",    myStats.get("luck"));
                nextMatchup.put("aiAttack",  aiStats.get("attack"));
                nextMatchup.put("aiDefense", aiStats.get("defense"));
                nextMatchup.put("aiMacro",   aiStats.get("macro"));
                nextMatchup.put("aiMicro",   aiStats.get("micro"));
                nextMatchup.put("aiLuck",    aiStats.get("luck"));
                nextMatchup.put("myRace",    myRace);
                nextMatchup.put("aiRace",    aiRace);
                nextMatchup.put("myBuild",   myBuildDto);
                nextMatchup.put("aiBuild",   aiBuildDto);
                nextMatchup.put("myCondition", myCondition);
                nextMatchup.put("myWinStreak", myWinStreak);
                nextMatchup.put("aiCondition", aiCondition);
                nextMatchup.put("aiWinStreak", aiWinStreak);

                boolean nextWinFlag = pveBattleService.calculateWinResults(
                    Collections.singletonList(nextMatchup)).get(0);

                // ★ 대본 시스템 폐기 — scriptLines 제거, ATB 엔진이 프론트에서 전투 진행
                List<String> nextScriptLines = Collections.emptyList();

                Map<String, Object> nextScriptData = new HashMap<>();
                nextScriptData.put("lines", nextScriptLines);
                nextScriptData.put("myWin", nextWinFlag);
                nextScriptData.put("myName", myPName);
                nextScriptData.put("aiName", aiPName);
                nextScriptData.put("mapId", nextMatchup.get("mapId")); // ★ 다음 세트에도 맵 ID 보장

                BattleProgressDTO progress = new BattleProgressDTO();
                progress.setUserId(userId);
                progress.setLevel(stageLevel);
                progress.setSubLevel(subLevel);
                progress.setMyWins(myWins);
                progress.setAiWins(aiWins);
                progress.setCurrentSet(nextSet);
                progress.setGameStateData(gson.toJson(nextScriptData)); // ★ 갱신된 게임상태 저장

                pveBattleService.saveProgress(progress);
            } catch (Exception e) { e.printStackTrace(); }
            response.put("victory", null);
        }

        response.put("success", true);
        return response;
    }

    // ========================================
    // 강화 시스템
    // ========================================

    private int getEnhanceSuccessRate(int currentLevel) {
        if (currentLevel < 10) return 90;
        if (currentLevel < 20) return 80;
        if (currentLevel < 30) return 70;
        if (currentLevel < 40) return 60;
        if (currentLevel < 50) return 50;
        if (currentLevel < 60) return 35;
        if (currentLevel < 70) return 25;
        if (currentLevel < 80) return 15;
        if (currentLevel < 90) return 8;
        return 3; 
    }

    @GetMapping("/enhance")
    public String enhancePage(HttpSession session, org.springframework.ui.Model model) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        List<OwnedPlayerInfoDTO> players = ownedPlayerDAO.selectOwnedPlayersByUserId(loginUser.getUserId());
        model.addAttribute("players", players);
        return "enhance";
    }

    @GetMapping("/enhance/info")
    @ResponseBody
    public Map<String, Object> getEnhanceInfo(@RequestParam("ownedPlayerSeq") int ownedPlayerSeq,
                                               HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { res.put("success", false); res.put("message", "로그인 필요"); return res; }

        OwnedPlayerDTO target = ownedPlayerDAO.selectOwnedPlayer(ownedPlayerSeq);
        if (target == null || !loginUser.getUserId().equals(target.getUserId())) {
            res.put("success", false); res.put("message", "선수를 찾을 수 없습니다."); return res;
        }

        List<OwnedPlayerDTO> materials = ownedPlayerDAO.selectMaterialCandidates(target);

        res.put("success", true);
        res.put("ownedPlayerSeq",  target.getOwnedPlayerSeq());
        res.put("enhanceLevel",    target.getEnhanceLevel());
        res.put("enhanceAttack",   target.getEnhanceAttack());
        res.put("enhanceDefense",  target.getEnhanceDefense());
        res.put("enhanceMacro",    target.getEnhanceMacro());
        res.put("enhanceMicro",    target.getEnhanceMicro());
        res.put("enhanceLuck",     target.getEnhanceLuck());
        res.put("enhanceStreak",   target.getEnhanceStreak());
        res.put("materialCount",   materials.size());
        res.put("successRate",     getEnhanceSuccessRate(target.getEnhanceLevel()));
        res.put("maxLevel",        99);
        return res;
    }

    @PostMapping("/enhance/execute")
    @ResponseBody
    public Map<String, Object> executeEnhance(@RequestParam("ownedPlayerSeq") int ownedPlayerSeq,
                                               HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) { res.put("success", false); res.put("message", "로그인 필요"); return res; }
        String userId = loginUser.getUserId();

        OwnedPlayerDTO target = ownedPlayerDAO.selectOwnedPlayer(ownedPlayerSeq);
        if (target == null || !userId.equals(target.getUserId())) {
            res.put("success", false); res.put("message", "선수를 찾을 수 없습니다."); return res;
        }
        if (target.getEnhanceLevel() >= 99) {
            res.put("success", false); res.put("message", "이미 최대 강화 단계입니다. (+99)"); return res;
        }

        List<OwnedPlayerDTO> materials = ownedPlayerDAO.selectMaterialCandidates(target);
        if (materials.isEmpty()) {
            res.put("success", false); res.put("message", "재료 선수가 없습니다. 동일한 선수(같은 팩)가 1장 더 필요합니다."); return res;
        }

        OwnedPlayerDTO material = materials.get(0);
        try {
            ownedPlayerDAO.deleteOwnedPlayer(material.getOwnedPlayerSeq());
        } catch (Exception e) {
            res.put("success", false); res.put("message", "재료 소모 중 오류 발생: " + e.getMessage()); return res;
        }

        int successRate = getEnhanceSuccessRate(target.getEnhanceLevel());
        boolean success = rand.nextInt(100) < successRate;

        res.put("successRate", successRate);
        res.put("success", true);
        res.put("enhanced", success);

        if (success) {
            String[] statNames = {"attack", "defense", "macro", "micro", "luck"};
            int statIdx = rand.nextInt(5);
            String statName = statNames[statIdx];

            int newLevel = target.getEnhanceLevel() + 1;
            target.setEnhanceLevel(newLevel);
            switch (statIdx) {
                case 0: target.setEnhanceAttack(target.getEnhanceAttack()   + 1); break;
                case 1: target.setEnhanceDefense(target.getEnhanceDefense() + 1); break;
                case 2: target.setEnhanceMacro(target.getEnhanceMacro()     + 1); break;
                case 3: target.setEnhanceMicro(target.getEnhanceMicro()     + 1); break;
                case 4: target.setEnhanceLuck(target.getEnhanceLuck()       + 1); break;
            }
            ownedPlayerDAO.updateEnhanceStats(target);

            int prevStreak = target.getEnhanceStreak();
            int newStreak  = prevStreak > 0 ? prevStreak + 1 : 1;
            target.setEnhanceStreak(newStreak);
            ownedPlayerDAO.updateEnhanceStreak(target);

            try {
                dailyMissionService.incrementMissionProgress(userId, "ENHANCE", 1);
            } catch (Exception e) {
                System.err.println("강화 미션 업데이트 실패: " + e.getMessage());
            }

            res.put("newEnhanceLevel",   target.getEnhanceLevel());
            res.put("enhancedStat",      statName);
            res.put("enhanceAttack",     target.getEnhanceAttack());
            res.put("enhanceDefense",    target.getEnhanceDefense());
            res.put("enhanceMacro",      target.getEnhanceMacro());
            res.put("enhanceMicro",      target.getEnhanceMicro());
            res.put("enhanceLuck",       target.getEnhanceLuck());
            res.put("enhanceStreak",     newStreak);
            res.put("message",           "+" + newLevel + " 강화 성공! " + statName + " +1");
        } else {
            int prevStreak = target.getEnhanceStreak();
            int newStreak  = prevStreak < 0 ? prevStreak - 1 : -1;
            target.setEnhanceStreak(newStreak);
            ownedPlayerDAO.updateEnhanceStreak(target);

            res.put("newEnhanceLevel",  target.getEnhanceLevel());
            res.put("enhanceStreak",    newStreak);
            res.put("message",          "강화 실패. 재료만 소모되었습니다.");
        }

        res.put("remainMaterials", materials.size() - 1);
        res.put("nextSuccessRate", getEnhanceSuccessRate(target.getEnhanceLevel()));
        return res;
    }

    private void cleanUpPveSession(HttpSession session) {
        session.removeAttribute("currentBattleId");
        session.removeAttribute("setResults");
        session.removeAttribute("simulationMatchupList");
        session.removeAttribute("simulationMyTeamName");
        session.removeAttribute("simulationOpponentTeamName");
        session.removeAttribute("currentSet");
        session.removeAttribute("myWins");
        session.removeAttribute("aiWins");
        session.removeAttribute("currentGameState");
    }

    private Map<String, Object> createNewMatchupList(
            String userId, int stageLevel, int subLevel,
            int[] myPlayerOwnedSeqs, int[] myBuildIds,
            Map<Integer, PveOpponentInfoDTO> aiPlayerMap,
            List<PveStageMapDTO> mapList) throws Exception {

        List<Map<String, Object>> matchupList = new ArrayList<>();
        List<SetResult> setResults = new ArrayList<>();
        Map<String, Object> result = new HashMap<>();

        Map<Integer, PveOpponentInfoDTO> opponentMap = (aiPlayerMap != null)
                ? aiPlayerMap
                : pveSubstageService.getOpponentMapForSubstage(stageLevel, subLevel);

        for (int setNum = 1; setNum <= 5; setNum++) {
            OwnedPlayerInfoDTO myPlayerDetails = null;
            if (myPlayerOwnedSeqs != null && myPlayerOwnedSeqs.length >= setNum && myPlayerOwnedSeqs[setNum - 1] > 0)
                myPlayerDetails = ownedPlayerDAO.selectOwnedPlayerDetails(myPlayerOwnedSeqs[setNum - 1]);

            int myBuildId = (myBuildIds != null && myBuildIds.length >= setNum) ? myBuildIds[setNum - 1] : 0;
            PveOpponentInfoDTO aiPlayerDetails = opponentMap.get(setNum);

            // ★ 맵 리스트 파라미터 추가
            Map<String, Object> matchup = createMatchupMap(myPlayerDetails, myBuildId, aiPlayerDetails, setNum, stageLevel, subLevel, mapList);
            matchupList.add(matchup);

            setResults.add(new SetResult(
                setNum,
                myPlayerDetails != null ? myPlayerDetails.getOwnedPlayerSeq() : 0,
                myPlayerDetails != null ? myPlayerDetails.getPlayerName() : "N/A",
                aiPlayerDetails != null ? aiPlayerDetails.getPlayerSeq() : 0,
                aiPlayerDetails != null ? aiPlayerDetails.getPlayerName() : "N/A",
                false
            ));
        }

        result.put("matchupList", matchupList);
        result.put("setResults", setResults);
        return result;
    }

    private Map<String, Object> createMatchupMap(
            OwnedPlayerInfoDTO myPlayer, int myBuildId,
            PveOpponentInfoDTO aiPlayer,
            int setNum, int stageLevel, int subLevel,
            List<PveStageMapDTO> mapList) {

        Map<String, Object> matchup = new HashMap<>();
        matchup.put("stageLevel", stageLevel);
        matchup.put("subLevel",   subLevel);
        matchup.put("setNumber",  setNum);
        
        // ★ 세트 번호에 맞는 맵 ID, 맵 이름 찾기
        String mapName = "Fighting Spirit";
        String mapId = null;
        if (mapList != null) {
            for (PveStageMapDTO map : mapList) {
                if (map.getSetNumber() == setNum) {
                    mapName = map.getMapName();
                    mapId = map.getMapId();
                    break;
                }
            }
        }
        matchup.put("mapName", mapName);
        matchup.put("mapId", mapId);

        if (myPlayer != null) {
            matchup.put("myOwnedPlayerSeq", myPlayer.getOwnedPlayerSeq());
            matchup.put("myPlayerSeq",      myPlayer.getPlayerSeq());
            matchup.put("myPlayerName",     myPlayer.getPlayerName());
            matchup.put("myPlayerImgUrl",   myPlayer.getPlayerImgUrl());
            matchup.put("myPlayerRace",     myPlayer.getRace());
            matchup.put("myPlayerRarity",   myPlayer.getCurrentRarity());
            matchup.put("myPlayerAttack",   myPlayer.getTotalAttack());
            matchup.put("myPlayerDefense",  myPlayer.getTotalDefense());
            matchup.put("myPlayerMacro",    myPlayer.getTotalMacro());
            matchup.put("myPlayerMicro",    myPlayer.getTotalMicro());
            matchup.put("myPlayerLuck",     myPlayer.getTotalLuck());
            matchup.put("myPlayerCondition", myPlayer.getCondition() != null ? myPlayer.getCondition() : "NORMAL");
            matchup.put("myPlayerWinStreak", myPlayer.getWinStreak());
            matchup.put("myPlayerPackName", myPlayer.getPackName());
            matchup.put("myPlayerTrait",    "맞춤형 전략 수행");

            if (myBuildId > 0) {
                BuildDTO myBuild = buildService.getBuildById(myBuildId);
                if (myBuild != null) {
                    matchup.put("myBuildId",   myBuildId);
                    matchup.put("myBuildName", myBuild.getBuildName());
                }
            }
        }

        if (aiPlayer != null) {
            matchup.put("aiPlayerSeq",     aiPlayer.getPlayerSeq());
            matchup.put("aiPlayerName",    aiPlayer.getPlayerName());
            matchup.put("aiPlayerImgUrl",  aiPlayer.getPlayerImgUrl());
            matchup.put("aiPlayerRace",    aiPlayer.getRace());
            matchup.put("aiPlayerRarity",  aiPlayer.getRarity());
            matchup.put("aiPlayerAttack",  aiPlayer.getStatAttack());
            matchup.put("aiPlayerDefense", aiPlayer.getStatDefense());
            matchup.put("aiPlayerMacro",   aiPlayer.getStatMacro());
            matchup.put("aiPlayerMicro",   aiPlayer.getStatMicro());
            matchup.put("aiPlayerLuck",    aiPlayer.getStatLuck());
            matchup.put("aiPlayerTrait",   "안정적인 운영 선호");

            Integer aiBuildId = null;
            if (myPlayer != null) {
                String userRace = myPlayer.getRace();
                if ("T".equals(userRace)) {
                    aiBuildId = aiPlayer.getBuildIdVsT();
                } else if ("Z".equals(userRace)) {
                    aiBuildId = aiPlayer.getBuildIdVsZ();
                } else if ("P".equals(userRace)) {
                    aiBuildId = aiPlayer.getBuildIdVsP();
                }
            }
            
            if (aiBuildId != null && aiBuildId > 0) {
                BuildDTO aiBuild = buildService.getBuildById(aiBuildId);
                if (aiBuild != null) {
                    matchup.put("aiBuildId",   aiBuildId);
                    matchup.put("aiBuildName", aiBuild.getBuildName());
                } else {
                    matchup.put("aiBuildName", "기본 AI 전략");
                }
            } else {
                matchup.put("aiBuildName", "기본 AI 전략");
            }
        }

        return matchup;
    }

    private List<PlayerDTO> getFeaturedPlayersFromContents(List<PackContentDTO> contents, int limit) {
        List<PlayerDTO> players = new ArrayList<>();
        if (contents != null && playerDAO != null) {
            int count = 0;
            for (PackContentDTO content : contents) {
                PlayerDTO player = playerDAO.selectPlayerBySeq(content.getPlayerSeq());
                if (player != null) {
                    players.add(player);
                    if (++count >= limit) break;
                }
            }
        }
        return players;
    }

    private int safeInt(Object val, int defaultVal) {
        if (val == null) return defaultVal;
        if (val instanceof Number) return ((Number) val).intValue();
        try { return Integer.parseInt(val.toString()); }
        catch (Exception e) { return defaultVal; }
    }

    private Map<String, Integer> extractStats(Map<String, Object> matchup, String prefix) {
        Map<String, Integer> stats = new HashMap<>();
        int atk  = safeInt(matchup.get(prefix + "Attack"),  50);
        int def  = safeInt(matchup.get(prefix + "Defense"), 50);
        int mac  = safeInt(matchup.get(prefix + "Macro"),   50);
        int mic  = safeInt(matchup.get(prefix + "Micro"),   50);
        int luk  = safeInt(matchup.get(prefix + "Luck"),    50);

        String condition = (String) matchup.getOrDefault(prefix + "Condition", "NORMAL");
        double condMult = 1.0;
        switch (condition) {
            case "PEAK":   condMult = 1.20; break; 
            case "GOOD":   condMult = 1.10; break; 
            case "NORMAL": condMult = 1.00; break; 
            case "TIRED":  condMult = 0.90; break; 
            case "WORST":  condMult = 0.80; break; 
        }

        int winStreak = safeInt(matchup.get(prefix + "WinStreak"), 0);
        double streakMult = 1.0;
        if (winStreak >= 5) {
            streakMult = 1.10;
        } else if (winStreak == 4) {
            streakMult = 1.08;
        } else if (winStreak == 3) {
            streakMult = 1.06;
        } else if (winStreak == 2) {
            streakMult = 1.03;
        } else {
            streakMult = 1.00;
        }

        double totalMult = condMult * streakMult;

        stats.put("attack",  (int) Math.round(atk * totalMult));
        stats.put("defense", (int) Math.round(def * totalMult));
        stats.put("macro",   (int) Math.round(mac * totalMult));
        stats.put("micro",   (int) Math.round(mic * totalMult));
        stats.put("luck",    (int) Math.round(luk * totalMult));
        
        return stats;
    }

    private Map<String, Object> applyBuildBasedStatIncrease(
            OwnedPlayerDTO player, BuildDTO build, int myTotal, int aiTotal) {

        Map<String, Object> changes = new HashMap<>();
        int a  = player.getCurrentAttack()  == 0 ? 50 : player.getCurrentAttack();
        int d  = player.getCurrentDefense() == 0 ? 50 : player.getCurrentDefense();
        int ma = player.getCurrentMacro()   == 0 ? 50 : player.getCurrentMacro();
        int mi = player.getCurrentMicro()   == 0 ? 50 : player.getCurrentMicro();
        int l  = player.getCurrentLuck()    == 0 ? 50 : player.getCurrentLuck();
        changes.put("beforeAttack", a);  changes.put("beforeDefense", d);
        changes.put("beforeMacro",  ma); changes.put("beforeMicro",   mi); changes.put("beforeLuck", l);

        int totalPoints;
        int diff = aiTotal - myTotal;
        if (diff > 50)       totalPoints = 3;  
        else if (diff > -50) totalPoints = 2;  
        else                 totalPoints = 1;  

        double[] w = {1.0, 1.0, 1.0, 1.0, 1.0};

        double wSum = w[0] + w[1] + w[2] + w[3] + w[4];
        int[] inc = new int[5];
        for (int i = 0; i < totalPoints; i++) {
            double r = rand.nextDouble() * wSum;
            double cum = 0;
            for (int j = 0; j < 5; j++) {
                cum += w[j];
                if (r < cum) { inc[j]++; break; }
            }
        }

        player.setCurrentAttack(a   + inc[0]); player.setCurrentDefense(d  + inc[1]);
        player.setCurrentMacro(ma   + inc[2]); player.setCurrentMicro(mi   + inc[3]);
        player.setCurrentLuck(l     + inc[4]);
        changes.put("afterAttack",  player.getCurrentAttack());
        changes.put("afterDefense", player.getCurrentDefense());
        changes.put("afterMacro",   player.getCurrentMacro());
        changes.put("afterMicro",   player.getCurrentMicro());
        changes.put("afterLuck",    player.getCurrentLuck());
        changes.put("attackInc",  inc[0]); changes.put("defenseInc", inc[1]);
        changes.put("macroInc",   inc[2]); changes.put("microInc",   inc[3]); changes.put("luckInc", inc[4]);
        changes.put("totalPointsGained", totalPoints);
        return changes;
    }

    private Map<String, Object> applyRandomStatDecrease(OwnedPlayerDTO player, int myTotal, int aiTotal) {
        Map<String, Object> changes = new HashMap<>();
        int a  = player.getCurrentAttack()  == 0 ? 50 : player.getCurrentAttack();
        int d  = player.getCurrentDefense() == 0 ? 50 : player.getCurrentDefense();
        int ma = player.getCurrentMacro()   == 0 ? 50 : player.getCurrentMacro();
        int mi = player.getCurrentMicro()   == 0 ? 50 : player.getCurrentMicro();
        int l  = player.getCurrentLuck()    == 0 ? 50 : player.getCurrentLuck();
        changes.put("beforeAttack", a);  changes.put("beforeDefense", d);
        changes.put("beforeMacro",  ma); changes.put("beforeMicro",   mi); changes.put("beforeLuck", l);
        
        int diff = aiTotal - myTotal;
        int totalDrop;
        if (diff > 50)       totalDrop = 1;  
        else if (diff > -50) totalDrop = 2;  
        else                 totalDrop = 3;  
        int rem = totalDrop; int[] dec = new int[5];
        while (rem-- > 0) dec[rand.nextInt(5)]++;
        player.setCurrentAttack(Math.max(1, a   - dec[0])); player.setCurrentDefense(Math.max(1, d  - dec[1]));
        player.setCurrentMacro(Math.max(1,  ma  - dec[2])); player.setCurrentMicro(Math.max(1,  mi - dec[3]));
        player.setCurrentLuck(Math.max(1,   l   - dec[4]));
        changes.put("afterAttack",  player.getCurrentAttack());
        changes.put("afterDefense", player.getCurrentDefense());
        changes.put("afterMacro",   player.getCurrentMacro());
        changes.put("afterMicro",   player.getCurrentMicro());
        changes.put("afterLuck",    player.getCurrentLuck());
        changes.put("attackInc",  -dec[0]); changes.put("defenseInc", -dec[1]);
        changes.put("macroInc",   -dec[2]); changes.put("microInc",   -dec[3]); changes.put("luckInc", -dec[4]);
        return changes;
    }
    
    // ========================================
    // 일일 미션 시스템
    // ========================================
    
    @GetMapping("/daily-missions")
    public String dailyMissionsPage(HttpSession session, Model model) {
        if (session.getAttribute("loginUser") == null) return "redirect:/login";
        
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        String userId = loginUser.getUserId();
        
        try {
            List<UserDailyMissionDTO> missions = dailyMissionService.getUserMissionsToday(userId);
            
            int totalMissions = missions.size();
            int completedMissions = (int) missions.stream().filter(m -> "Y".equals(m.getIsCompleted())).count();
            int claimedMissions = (int) missions.stream().filter(m -> "Y".equals(m.getIsClaimed())).count();
            int totalRewards = missions.stream()
                    .filter(m -> "Y".equals(m.getIsCompleted()) && "N".equals(m.getIsClaimed()))
                    .mapToInt(UserDailyMissionDTO::getRewardCrystal)
                    .sum();
            
            model.addAttribute("missions", missions);
            model.addAttribute("totalMissions", totalMissions);
            model.addAttribute("completedMissions", completedMissions);
            model.addAttribute("claimedMissions", claimedMissions);
            model.addAttribute("totalRewards", totalRewards);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("missions", new ArrayList<>());
            model.addAttribute("errorMessage", "미션 정보를 불러오는 데 실패했습니다.");
        }
        
        return "dailyMissions";
    }
    
    @PostMapping("/daily-missions/claim")
    @ResponseBody
    public Map<String, Object> claimMissionReward(@RequestParam("missionId") int missionId, 
                                                   HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }
            
            String userId = loginUser.getUserId();
            
            int rewardAmount = dailyMissionService.claimMissionReward(userId, missionId);
            
            UserDTO updatedUser = userDAO.selectUserCurrency(userId);
            session.setAttribute("loginUser", updatedUser);
            
            result.put("success", true);
            result.put("message", "보상을 수령했습니다!");
            result.put("rewardAmount", rewardAmount);
            result.put("newCrystal", updatedUser.getCrystal());
            
        } catch (IllegalStateException e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "보상 수령 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return result;
    }
    
    @PostMapping("/daily-missions/claim-all")
    @ResponseBody
    public Map<String, Object> claimAllRewards(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }
            
            String userId = loginUser.getUserId();
            
            List<UserDailyMissionDTO> missions = dailyMissionService.getUserMissionsToday(userId);
            int totalReward = 0;
            int claimedCount = 0;
            
            for (UserDailyMissionDTO mission : missions) {
                if (mission.canClaim()) {
                    try {
                        int reward = dailyMissionService.claimMissionReward(userId, mission.getMissionId());
                        totalReward += reward;
                        claimedCount++;
                    } catch (Exception e) {
                        System.err.println("미션 " + mission.getMissionId() + " 수령 실패: " + e.getMessage());
                    }
                }
            }
            
            UserDTO updatedUser = userDAO.selectUserCurrency(userId);
            session.setAttribute("loginUser", updatedUser);
            
            result.put("success", true);
            result.put("message", claimedCount + "개의 보상을 수령했습니다!");
            result.put("claimedCount", claimedCount);
            result.put("totalReward", totalReward);
            result.put("newCrystal", updatedUser.getCrystal());
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "보상 수령 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return result;
    }
    
    @GetMapping("/daily-missions/claimable-count")
    @ResponseBody
    public Map<String, Object> getClaimableCount(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("count", 0);
                return result;
            }
            
            String userId = loginUser.getUserId();
            int count = dailyMissionService.getClaimableRewardCount(userId);
            
            result.put("count", count);
            
        } catch (Exception e) {
            result.put("count", 0);
            e.printStackTrace();
        }
        
        return result;
    }
}